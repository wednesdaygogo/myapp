import 'package:isar/isar.dart';

part 'health_indicator.g.dart';

enum IndicatorType {
  bloodGlucose,
  bloodPressure,
  bloodLipidTC,
  bloodLipidTG,
  bloodLipidHDL,
  bloodLipidLDL,
}

@Collection()
class HealthIndicator {
  Id id = Isar.autoIncrement;

  @Index()
  int reportId = 0;

  // Indicator type (store enum as ordinal in Isar)
  @Enumerated(EnumType.ordinal)
  IndicatorType type = IndicatorType.bloodGlucose;

  double value = 0.0;
  String unit = ''; // 'mmol/L', 'mmHg'
  bool isAbnormal = false;

  // For blood pressure (systolic/diastolic)
  double? secondValue;
}
