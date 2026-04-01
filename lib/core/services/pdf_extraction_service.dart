import 'dart:io';
import 'dart:typed_data';

/// PDF extraction result
class PdfExtractionResult {
  final String text;
  final bool success;
  final String? errorMessage;

  PdfExtractionResult({
    required this.text,
    required this.success,
    this.errorMessage,
  });

  factory PdfExtractionResult.success(String text) =>
      PdfExtractionResult(text: text, success: true);

  factory PdfExtractionResult.failure(String error) =>
      PdfExtractionResult(text: '', success: false, errorMessage: error);

  factory PdfExtractionResult.empty() =>
      PdfExtractionResult(text: '', success: true);
}

/// Service for extracting text from PDF health examination reports
class PdfExtractionService {
  /// Max file size: 20MB
  static const int maxFileSizeBytes = 20 * 1024 * 1024;

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

  /// Extract text from PDF bytes
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

      // Extract text from PDF content
      final text = _parsePdfContent(pdfBytes);

      if (text.isEmpty) {
        // PDF might be image-based (scanned document)
        return PdfExtractionResult.empty();
      }

      return PdfExtractionResult.success(text);
    } catch (e) {
      return PdfExtractionResult.failure('PDF解析失败: ${e.toString()}');
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

  /// Parse PDF content to extract text
  String _parsePdfContent(Uint8List bytes) {
    try {
      // Convert bytes to string for parsing (filter printable characters)
      final content = String.fromCharCodes(
        bytes.where((b) => b != 0 && (b >= 32 || b == 10 || b == 13)),
      );

      final textBuffer = StringBuffer();

      // Method 1: Extract text from stream objects
      final streamRegex = RegExp(r'stream\s*\n(.*?)\nendstream', dotAll: true);
      for (final match in streamRegex.allMatches(content)) {
        final streamContent = match.group(1) ?? '';
        _extractTextFromStream(streamContent, textBuffer);
      }

      // Method 2: Also look for text in the raw content
      _extractTextFromRawContent(content, textBuffer);

      return textBuffer.toString().trim();
    } catch (e) {
      return '';
    }
  }

  /// Extract text from a PDF stream
  void _extractTextFromStream(String streamContent, StringBuffer textBuffer) {
    // Parse Tj operator (single text string)
    final tjRegex = RegExp(r'\(([^)]+)\)\s*Tj');
    for (final tjMatch in tjRegex.allMatches(streamContent)) {
      final text = tjMatch.group(1) ?? '';
      if (text.isNotEmpty && !_isPdfOperator(text)) {
        textBuffer.write(text);
        textBuffer.write(' ');
      }
    }

    // Parse TJ operator (array of text strings)
    final tjArrayRegex = RegExp(r'\[(.*?)\]\s*TJ', dotAll: true);
    for (final tjArrayMatch in tjArrayRegex.allMatches(streamContent)) {
      final arrayContent = tjArrayMatch.group(1) ?? '';
      final stringRegex = RegExp(r'\(([^)]+)\)');
      for (final strMatch in stringRegex.allMatches(arrayContent)) {
        final text = strMatch.group(1) ?? '';
        if (text.isNotEmpty && !_isPdfOperator(text)) {
          textBuffer.write(text);
        }
      }
      textBuffer.write(' ');
    }

    // Also look for hex strings <...>
    final hexRegex = RegExp(r'<([0-9A-Fa-f]+)>\s*Tj');
    for (final hexMatch in hexRegex.allMatches(streamContent)) {
      final hex = hexMatch.group(1) ?? '';
      if (hex.isNotEmpty) {
        try {
          final decoded = _decodeHexString(hex);
          if (decoded.isNotEmpty) {
            textBuffer.write(decoded);
            textBuffer.write(' ');
          }
        } catch (e) {
          // Ignore decoding errors
        }
      }
    }
  }

  /// Extract text from raw PDF content
  void _extractTextFromRawContent(String content, StringBuffer textBuffer) {
    // Look for common patterns in Chinese health reports
    final patterns = [
      // Blood glucose patterns
      RegExp(r'(?:空腹|餐后)?血糖[^\d]*(\d+\.?\d*)\s*(?:mmol/L)?'),
      // Blood pressure patterns
      RegExp(r'血压[^\d]*(\d+)/(\d+)\s*(?:mmHg)?'),
      // Cholesterol patterns
      RegExp(r'(?:总胆固醇|TC)[^\d]*(\d+\.?\d*)\s*(?:mmol/L)?'),
      RegExp(r'(?:甘油三酯|TG)[^\d]*(\d+\.?\d*)\s*(?:mmol/L)?'),
      RegExp(r'(?:高密度脂蛋白|HDL)[^\d]*(\d+\.?\d*)\s*(?:mmol/L)?'),
      RegExp(r'(?:低密度脂蛋白|LDL)[^\d]*(\d+\.?\d*)\s*(?:mmol/L)?'),
    ];

    for (final pattern in patterns) {
      for (final match in pattern.allMatches(content)) {
        final matchedText = match.group(0) ?? '';
        textBuffer.writeln(matchedText);
      }
    }
  }

  /// Check if text is a PDF operator (not actual content)
  bool _isPdfOperator(String text) {
    const operators = [
      'BT',
      'ET',
      'Td',
      'TD',
      'Tm',
      'T*',
      'Tj',
      'TJ',
      'Ts',
      'Tw',
      'Tc',
      'Tf',
      'TL',
      'Tr',
      'q',
      'Q',
      'cm',
      'gs',
      'ri',
      'cs',
      'CS',
      'sc',
      'SC',
      'scn',
      'SCN',
      'G',
      'g',
      'RG',
      'rg',
      'K',
      'k',
      'sh',
      're',
      'm',
      'l',
      'c',
      'v',
      'y',
      'h',
      'B',
      'B*',
      'b',
      'b*',
      'n',
      'W',
      'W*',
      'f',
      'F',
      'f*',
      'S',
      's',
      'Do',
      'BI',
      'ID',
      'EI',
    ];
    return operators.contains(text.trim());
  }

  /// Decode hex string to text
  String _decodeHexString(String hex) {
    final buffer = StringBuffer();
    for (int i = 0; i < hex.length; i += 2) {
      if (i + 1 < hex.length) {
        final code = int.tryParse(hex.substring(i, i + 2), radix: 16);
        if (code != null && code > 31) {
          buffer.writeCharCode(code);
        }
      }
    }
    return buffer.toString();
  }

  /// Get file name from path
  String getFileName(String path) {
    return path.split('/').last;
  }
}
