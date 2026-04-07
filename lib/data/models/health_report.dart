import 'package:hive/hive.dart';

part 'health_report.g.dart';

@HiveType(typeId: 1)
class HealthReport extends HiveObject {
  @HiveField(4)
  int id;

  @HiveField(0)
  int personId;

  @HiveField(1)
  DateTime reportDate;

  @HiveField(2)
  String source;

  @HiveField(3)
  String? pdfPath;

  @HiveField(5)
  String? fileName; // Store original filename for display

  @HiveField(6)
  List<int>? pdfBytes; // Store PDF bytes for Web platform

  HealthReport({
    this.id = 0,
    required this.personId,
    required this.reportDate,
    this.source = 'manual',
    this.pdfPath,
    this.fileName,
    this.pdfBytes,
  });
}
