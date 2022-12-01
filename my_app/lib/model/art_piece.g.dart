// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'art_piece.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArtPieceAdapter extends TypeAdapter<ArtPiece> {
  @override
  final int typeId = 0;

  @override
  ArtPiece read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ArtPiece(
      id: fields[3] as int,
      title: fields[0] as String,
      image: fields[1] as String,
      description: fields[2] as String,
      data: (fields[4] as Map).cast<dynamic, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ArtPiece obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.image)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArtPieceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
