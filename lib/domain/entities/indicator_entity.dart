enum IndicatorType {
  bloodGlucose,
  bloodPressure,
  bloodLipidTC,
  bloodLipidTG,
  bloodLipidHDL,
  bloodLipidLDL,
  custom,
}

class IndicatorEntity {
  final int? id;
  final int reportId;
  final IndicatorType type;
  final double value;
  final double? secondValue;
  final String unit;
  final bool isAbnormal;

  IndicatorEntity({
    this.id,
    required this.reportId,
    required this.type,
    required this.value,
    this.secondValue,
    required this.unit,
    required this.isAbnormal,
  });

  String get statusText => isAbnormal ? '异常' : '正常';

  String get displayName {
    switch (type) {
      case IndicatorType.bloodGlucose:
        return '血糖';
      case IndicatorType.bloodPressure:
        return '血压';
      case IndicatorType.bloodLipidTC:
        return '总胆固醇';
      case IndicatorType.bloodLipidTG:
        return '甘油三酯';
      case IndicatorType.bloodLipidHDL:
        return '高密度脂蛋白';
      case IndicatorType.bloodLipidLDL:
        return '低密度脂蛋白';
      case IndicatorType.custom:
        return '自定义';
    }
  }
}
