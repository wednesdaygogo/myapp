import 'package:hive/hive.dart';

part 'person.g.dart';

@HiveType(typeId: 0)
class Person extends HiveObject {
  @HiveField(7)
  int id;

  @HiveField(0)
  String name;

  @HiveField(1)
  String? gender;

  @HiveField(2)
  DateTime? birthDate;

  @HiveField(3)
  String? idNumber;

  @HiveField(4)
  String? phone;

  @HiveField(5)
  String? photoPath;

  @HiveField(6)
  String? relationship;

  Person({
    this.id = 0,
    required this.name,
    this.gender,
    this.birthDate,
    this.idNumber,
    this.phone,
    this.photoPath,
    this.relationship,
  });

  int get age {
    if (birthDate == null) return 0;
    final now = DateTime.now();
    int years = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      years--;
    }
    return years;
  }
}
