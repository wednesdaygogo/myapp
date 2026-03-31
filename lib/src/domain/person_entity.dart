class PersonEntity {
  final int id;
  String name;
  DateTime birthDate;

  PersonEntity({required this.id, required this.name, required this.birthDate});

  int get age {
    final now = DateTime.now();
    int calculated = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      calculated--;
    }
    return calculated;
  }
}
