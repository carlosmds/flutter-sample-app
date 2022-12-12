import 'package:hive/hive.dart';

part 'art_piece.g.dart';

@HiveType(typeId: 0)
class ArtPiece {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String image;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final int id;

  ArtPiece({
    required this.id,
    required this.title,
    required this.image,
    required this.description,
  });

  @override
  bool operator ==(Object other) => other is ArtPiece && id == other.id;
}
