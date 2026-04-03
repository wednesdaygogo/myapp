// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_report.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HealthReportAdapter extends TypeAdapter<HealthReport> {
  @override
  final int typeId = 1;

  @override
  HealthReport read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HealthReport(
      id: fields[4] as int,
      personId: fields[0] as int,
      reportDate: fields[1] as DateTime,
      source: fields[2] as String,
      pdfPath: fields[3] as String?,
      fileName: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HealthReport obj) {
    writer
      ..writeByte(6)
      ..writeByte(4)
      ..write(obj.id)
      ..writeByte(0)
      ..write(obj.personId)
      ..writeByte(1)
      ..write(obj.reportDate)
      ..writeByte(2)
      ..write(obj.source)
      ..writeByte(3)
      ..write(obj.pdfPath)
      ..writeByte(5)
      ..write(obj.fileName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthReportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
