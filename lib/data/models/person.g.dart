// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PersonAdapter extends TypeAdapter<Person> {
  @override
  final int typeId = 0;

  @override
  Person read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Person(
      id: fields[7] as int,
      name: fields[0] as String,
      gender: fields[1] as String?,
      birthDate: fields[2] as DateTime?,
      idNumber: fields[3] as String?,
      phone: fields[4] as String?,
      photoPath: fields[5] as String?,
      relationship: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Person obj) {
    writer
      ..writeByte(8)
      ..writeByte(7)
      ..write(obj.id)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.gender)
      ..writeByte(2)
      ..write(obj.birthDate)
      ..writeByte(3)
      ..write(obj.idNumber)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.photoPath)
      ..writeByte(6)
      ..write(obj.relationship);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
