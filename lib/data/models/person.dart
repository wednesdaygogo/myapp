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

  @HiveField(8)
  int? fatherId;

  @HiveField(9)
  int? motherId;

  @HiveField(10)
  int? spouseId;

  Person({
    this.id = 0,
    required this.name,
    this.gender,
    this.birthDate,
    this.idNumber,
    this.phone,
    this.photoPath,
    this.relationship,
    this.fatherId,
    this.motherId,
    this.spouseId,
  });

  /// 是否为男性
  bool isMale() => gender == '男';

  /// 是否为女性
  bool isFemale() => gender == '女';

  /// 获取所有父母ID
  List<int> getParentIds() {
    final ids = <int>[];
    if (fatherId != null) ids.add(fatherId!);
    if (motherId != null) ids.add(motherId!);
    return ids;
  }

  /// 是否有父母信息
  bool hasParents() => fatherId != null || motherId != null;

  /// 是否有配偶
  bool hasSpouse() => spouseId != null;

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
