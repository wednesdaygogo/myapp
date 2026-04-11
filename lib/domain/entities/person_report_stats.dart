class PersonReportStats {
  final int personId;
  final int reportCount;
  final DateTime? latestReportDate;

  const PersonReportStats({
    required this.personId,
    required this.reportCount,
    this.latestReportDate,
  });

  String get latestReportDateText {
    if (latestReportDate == null) return '';
    return '${latestReportDate!.year}-${latestReportDate!.month.toString().padLeft(2, '0')}';
  }
}