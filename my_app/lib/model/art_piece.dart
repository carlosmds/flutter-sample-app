class ArtPiece {
  final String title, image, description;
  final int id;
  final Map data;

  ArtPiece(
      {required this.id,
      required this.title,
      required this.image,
      required this.description,
      required this.data});

  @override
  bool operator ==(Object other) => other is ArtPiece && id == other.id;

  // maybe someday??
  // factory ArtPiece.fromJson(Map<String, dynamic> json) {
  //   return ArtPiece(
  //       title: json['title'],
  //       image: json['primaryImage'],
  //       description: json['objectName'],
  //       data: json);
  // }
}
