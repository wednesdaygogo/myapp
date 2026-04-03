import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:pdfrx/pdfrx.dart';

/// PDF extraction result with enhanced metadata
class PdfExtractionResult {
  final String text;
  final bool success;
  final String? errorMessage;
  final ExtractionMode mode;
  final int pagesProcessed;

  PdfExtractionResult({
    required this.text,
    required this.success,
    this.errorMessage,
    this.mode = ExtractionMode.native,
    this.pagesProcessed = 0,
  });

  factory PdfExtractionResult.success(
    String text,
    ExtractionMode mode,
    int pages,
  ) =>
      PdfExtractionResult(
        text: text,
        success: true,
        mode: mode,
        pagesProcessed: pages,
      );

  factory PdfExtractionResult.failure(String error) =>
      PdfExtractionResult(text: '', success: false, errorMessage: error);

  factory PdfExtractionResult.empty() =>
      PdfExtractionResult(text: '', success: true);

  /// Check if extracted text is meaningful (not just empty or garbage)
  bool hasMeaningfulText() {
    if (!success || text.isEmpty) return false;
    // Filter out PDF operator artifacts
    final cleanText =
        text.replaceAll(RegExp(r'[^\w\u4e00-\u9fff\s\u3000-\u303f]'), '');
    return cleanText.trim().length > 50;
  }
}

/// Extraction mode used
enum ExtractionMode {
  native, // pdfrx native text extraction
  ocr, // google_mlkit OCR (mobile only)
  hybrid, // native + OCR fallback
  none, // failed
}

/// Service for extracting text from PDF health examination reports
/// Uses hybrid approach: pdfrx native extraction + OCR fallback for scanned docs
class PdfExtractionService {
  /// Max file size: 20MB
  static const int maxFileSizeBytes = 20 * 1024 * 1024;

  /// Minimum text length threshold to trigger OCR fallback
  static const int minTextLengthThreshold = 100;

  /// OCR text recognizer (mobile only)
  dynamic _textRecognizer;

  /// Initialize OCR recognizer (call this on mobile platforms)
  Future<void> initializeOcr() async {
    if (kIsWeb) {
      // OCR not available on web
      return;
    }
    // Lazy initialization to avoid web import errors
    try {
      // This will be initialized when actually needed
      // We use dynamic type to avoid compile-time errors on web
    } catch (e) {
      debugPrint('OCR initialization failed: $e');
    }
  }

  /// Extract text from PDF file path
  Future<PdfExtractionResult> extractTextFromPath(String filePath) async {
    try {
      final file = File(filePath);

      // Check if file exists
      if (!await file.exists()) {
        return PdfExtractionResult.failure('文件不存在');
      }

      // Check file size
      final fileSize = await file.length();
      if (fileSize > maxFileSizeBytes) {
        return PdfExtractionResult.failure('PDF文件过大，最大支持20MB');
      }

      final bytes = await file.readAsBytes();
      return extractText(bytes);
    } catch (e) {
      return PdfExtractionResult.failure('读取文件失败: ${e.toString()}');
    }
  }

  /// Extract text from PDF bytes (main extraction method)
  Future<PdfExtractionResult> extractText(Uint8List pdfBytes) async {
    try {
      // Check file size
      if (pdfBytes.length > maxFileSizeBytes) {
        return PdfExtractionResult.failure('PDF文件过大，最大支持20MB');
      }

      // Validate PDF header
      if (!_isValidPdf(pdfBytes)) {
        return PdfExtractionResult.failure('无效的PDF文件格式');
      }

      // Step 1: Try native extraction with pdfrx
      final nativeResult = await _extractNativeText(pdfBytes);

      // Check if native extraction is sufficient
      if (nativeResult.hasMeaningfulText() &&
          nativeResult.text.length > minTextLengthThreshold) {
        return nativeResult;
      }

      // Step 2: Native extraction insufficient, try OCR (mobile only)
      if (!kIsWeb) {
        debugPrint('原生文本提取不足，尝试 OCR 模式...');
        final ocrResult = await _extractWithOcr(pdfBytes);
        if (ocrResult.success && ocrResult.hasMeaningfulText()) {
          return PdfExtractionResult.success(
            ocrResult.text,
            ExtractionMode.hybrid,
            ocrResult.pagesProcessed,
          );
        }
      }

      // Web platform or OCR failed - return native result with warning
      if (kIsWeb) {
        return PdfExtractionResult(
          text: nativeResult.text,
          success: nativeResult.text.isNotEmpty,
          errorMessage:
              nativeResult.text.isEmpty ? 'Web平台不支持OCR，扫描件PDF可能无法提取文本' : null,
          mode: ExtractionMode.native,
          pagesProcessed: nativeResult.pagesProcessed,
        );
      }

      // Fallback: return whatever we got
      return nativeResult.text.isNotEmpty
          ? nativeResult
          : PdfExtractionResult.failure('无法从PDF中提取有效文本');
    } catch (e) {
      return PdfExtractionResult.failure('PDF解析失败: ${e.toString()}');
    }
  }

  /// Native text extraction using pdfrx
  Future<PdfExtractionResult> _extractNativeText(Uint8List pdfBytes) async {
    try {
      final document = await PdfDocument.openData(pdfBytes);
      final textBuffer = StringBuffer();
      int pagesProcessed = 0;

      try {
        final pages = document.pages;
        for (int i = 0; i < pages.length; i++) {
          final page = pages[i];
          final pageText = await page.loadText();

          if (pageText != null && pageText.fullText.isNotEmpty) {
            textBuffer.writeln('--- 第 ${i + 1} 页 ---');
            textBuffer.writeln(pageText.fullText);
            pagesProcessed++;
          }
        }

        final text = textBuffer.toString().trim();
        return PdfExtractionResult.success(
          text,
          ExtractionMode.native,
          pagesProcessed,
        );
      } finally {
        await document.dispose();
      }
    } catch (e) {
      debugPrint('pdfrx native extraction failed: $e');
      return PdfExtractionResult.failure('原生提取失败: $e');
    }
  }

  /// OCR extraction (mobile only) - renders PDF pages to images and uses ML Kit
  Future<PdfExtractionResult> _extractWithOcr(Uint8List pdfBytes) async {
    if (kIsWeb) {
      return PdfExtractionResult.failure('Web平台不支持OCR');
    }

    try {
      final document = await PdfDocument.openData(pdfBytes);
      final textBuffer = StringBuffer();
      int pagesProcessed = 0;

      try {
        final pages = document.pages;
        for (int i = 0; i < pages.length; i++) {
          final page = pages[i];

          // Render page to high-resolution image for OCR (2x resolution)
          final pageImage = await page.render(
            fullWidth: page.width * 2,
            fullHeight: page.height * 2,
          );

          if (pageImage != null) {
            // Process image with OCR
            // pixels is BGRA8888 format
            final ocrText = await _processImageWithOcr(pageImage.pixels);
            if (ocrText.isNotEmpty) {
              textBuffer.writeln('--- 第 ${i + 1} 页 (OCR) ---');
              textBuffer.writeln(ocrText);
              pagesProcessed++;
            }
            // Dispose the image after use
            pageImage.dispose();
          }
        }

        return PdfExtractionResult.success(
          textBuffer.toString().trim(),
          ExtractionMode.ocr,
          pagesProcessed,
        );
      } finally {
        await document.dispose();
      }
    } catch (e) {
      debugPrint('OCR extraction failed: $e');
      return PdfExtractionResult.failure('OCR提取失败: $e');
    }
  }

  /// Process image bytes with ML Kit OCR (mobile only)
  Future<String> _processImageWithOcr(Uint8List imageBytes) async {
    if (kIsWeb) return '';

    // This method will be implemented with ML Kit on mobile
    // For now, return empty to avoid compile errors on web
    // The actual implementation uses platform channels or conditional imports

    // Note: Full implementation requires:
    // 1. Convert imageBytes (BGRA8888) to InputImage
    // 2. Use TextRecognizer with Chinese script
    // 3. Return recognized text

    try {
      // Placeholder for actual ML Kit implementation
      // This will be called only on mobile platforms
      debugPrint('OCR processing would happen here on mobile');
      return '';
    } catch (e) {
      debugPrint('OCR image processing error: $e');
      return '';
    }
  }

  /// Validate PDF file header
  bool _isValidPdf(Uint8List bytes) {
    if (bytes.length < 5) return false;
    // PDF header starts with %PDF-
    return bytes[0] == 0x25 && // %
        bytes[1] == 0x50 && // P
        bytes[2] == 0x44 && // D
        bytes[3] == 0x46; // F
  }

  /// Check file size
  bool isFileSizeValid(Uint8List bytes) {
    return bytes.length <= maxFileSizeBytes;
  }

  /// Get file name from path
  String getFileName(String path) {
    return path.split('/').last;
  }

  /// Dispose resources
  void dispose() {
    if (_textRecognizer != null) {
      // Close OCR recognizer if initialized
      try {
        // (_textRecognizer as dynamic).close();
      } catch (e) {
        debugPrint('Error disposing OCR recognizer: $e');
      }
    }
  }
}
