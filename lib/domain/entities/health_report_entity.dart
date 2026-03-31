enum ReportSource { pdf, manual }

class HealthReportEntity {
  final int? id;
  final int personId;
  final DateTime reportDate;
  final ReportSource source;
  final String? pdfPath;

  HealthReportEntity({
    this.id,
    required this.personId,
    required this.reportDate,
    required this.source,
    this.pdfPath,
  });

  HealthReportEntity copyWith({
    int? id,
    int? personId,
    DateTime? reportDate,
    ReportSource? source,
    String? pdfPath,
  }) {
    return HealthReportEntity(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      reportDate: reportDate ?? this.reportDate,
      source: source ?? this.source,
      pdfPath: pdfPath ?? this.pdfPath,
    );
  }
}
