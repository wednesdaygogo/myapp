class PersonEntity {
  final int? id;
  final String name;
  final String? gender;
  final DateTime? birthDate;
  final String? idNumber;
  final String? phone;
  final String? photoPath;
  final String? relationship;

  PersonEntity({
    this.id,
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

  PersonEntity copyWith({
    int? id,
    String? name,
    String? gender,
    DateTime? birthDate,
    String? idNumber,
    String? phone,
    String? photoPath,
    String? relationship,
  }) {
    return PersonEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      idNumber: idNumber ?? this.idNumber,
      phone: phone ?? this.phone,
      photoPath: photoPath ?? this.photoPath,
      relationship: relationship ?? this.relationship,
    );
  }
}
