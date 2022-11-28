class ArtPiece {
  final String title, image, description;
  final int id;
  final Map data;

  bool liked = false;

  ArtPiece(
      {required this.id,
      required this.title,
      required this.image,
      required this.description,
      required this.liked,
      required this.data});

  void toggleLiked() {
    liked = !liked;
  }

  // maybe someday??
  // factory ArtPiece.fromJson(Map<String, dynamic> json) {
  //   return ArtPiece(
  //       title: json['title'],
  //       image: json['primaryImage'],
  //       description: json['objectName'],
  //       liked: false,
  //       data: json);
  // }
}
