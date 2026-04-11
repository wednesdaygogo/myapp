class IndicatorDataPoint {
  final DateTime date;
  final double value;
  final double? secondValue;
  final int reportId;
  final bool isAbnormal;

  const IndicatorDataPoint({
    required this.date,
    required this.value,
    this.secondValue,
    required this.reportId,
    this.isAbnormal = false,
  });
}