import 'package:isar/isar.dart';
import 'person.dart';

part 'health_report.g.dart';

@Collection()
class HealthReport {
  Id id = Isar.autoIncrement;

  @Index()
  int personId = 0;

  DateTime reportDate = DateTime.now();
  String source = 'manual'; // 'pdf' or 'manual'
  String? pdfPath;

  // Link to person
  final person = IsarLink<Person>();
}
