import 'package:isar/isar.dart';

part 'person.g.dart';

@Collection()
class Person {
  Id id = Isar.autoIncrement;

  @Index()
  String name = ''; // Required

  String? gender; // '男', '女', '其他'
  DateTime? birthDate;
  String? idNumber;
  String? phone;
  String? photoPath;
  String? relationship; // '本人', '配偶', '父亲', '母亲', etc.

  // Computed age (not stored)
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
