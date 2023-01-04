// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocationModelAdapter extends TypeAdapter<LocationModel> {
  @override
  final int typeId = 1;

  @override
  LocationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationModel(
      id: fields[0] as int?,
      name: fields[1] as String?,
      type: fields[2] as String?,
      dimension: fields[3] as String?,
      residents: (fields[4] as List?)?.cast<String>(),
      url: fields[5] as String?,
      created: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LocationModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.dimension)
      ..writeByte(4)
      ..write(obj.residents)
      ..writeByte(5)
      ..write(obj.url)
      ..writeByte(6)
      ..write(obj.created);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
