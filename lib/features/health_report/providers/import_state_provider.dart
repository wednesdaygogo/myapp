import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ImportStatus {
  idle,
  fileSelected,
  extracting,
  parsing,
  saving,
  success,
  error,
  manualEntry,
}

class ImportState {
  final ImportStatus status;
  final String? filePath;
  final String? extractedText;
  final String? errorMessage;
  final int? reportId;

  ImportState({
    this.status = ImportStatus.idle,
    this.filePath,
    this.extractedText,
    this.errorMessage,
    this.reportId,
  });

  ImportState copyWith({
    ImportStatus? status,
    String? filePath,
    String? extractedText,
    String? errorMessage,
    int? reportId,
  }) {
    return ImportState(
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
      extractedText: extractedText ?? this.extractedText,
      errorMessage: errorMessage ?? this.errorMessage,
      reportId: reportId ?? this.reportId,
    );
  }

  bool get isLoading =>
      status == ImportStatus.extracting ||
      status == ImportStatus.parsing ||
      status == ImportStatus.saving;
}

class ImportNotifier extends StateNotifier<ImportState> {
  ImportNotifier() : super(ImportState());

  void selectFile(String path) {
    state = state.copyWith(status: ImportStatus.fileSelected, filePath: path);
  }

  void startExtraction() {
    state = state.copyWith(status: ImportStatus.extracting);
  }

  void extractionComplete(String text) {
    state = state.copyWith(status: ImportStatus.parsing, extractedText: text);
  }

  void extractionError(String error) {
    state = state.copyWith(status: ImportStatus.error, errorMessage: error);
  }

  void parsingComplete() {
    state = state.copyWith(status: ImportStatus.saving);
  }

  void parsingNeedsManualEntry() {
    state = state.copyWith(status: ImportStatus.manualEntry);
  }

  void saveSuccess(int reportId) {
    state = state.copyWith(status: ImportStatus.success, reportId: reportId);
  }

  void saveError(String error) {
    state = state.copyWith(status: ImportStatus.error, errorMessage: error);
  }

  void reset() {
    state = ImportState();
  }
}

final importProvider =
    StateNotifierProvider<ImportNotifier, ImportState>((ref) {
  return ImportNotifier();
});
