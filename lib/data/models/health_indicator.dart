import 'package:hive/hive.dart';

part 'health_indicator.g.dart';

@HiveType(typeId: 2)
class HealthIndicator extends HiveObject {
  @HiveField(6)
  int id;

  @HiveField(0)
  int reportId;

  @HiveField(1)
  String type;

  @HiveField(2)
  double value;

  @HiveField(3)
  double? secondValue;

  @HiveField(4)
  String unit;

  @HiveField(5)
  bool isAbnormal;

  HealthIndicator({
    this.id = 0,
    required this.reportId,
    required this.type,
    this.value = 0,
    this.secondValue,
    this.unit = '',
    this.isAbnormal = false,
  });
}
