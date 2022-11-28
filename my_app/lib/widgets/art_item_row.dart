import 'package:flutter/material.dart';

import '../model/art_piece.dart';

class ArtItemRow {
  static const _biggerFont =
      TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  static const _artImageBoxMinSize = 44.0;
  static const _artImageBoxMaxSize = 64.0;

  static ListTile buildRow(
      ArtPiece artPiece, VoidCallback onTap, VoidCallback onLike) {
    return ListTile(
      title: Text(
        artPiece.title,
        style: _biggerFont,
      ),
      subtitle: Text(artPiece.description),
      leading: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: _artImageBoxMinSize,
          minHeight: _artImageBoxMinSize,
          maxWidth: _artImageBoxMaxSize,
          maxHeight: _artImageBoxMaxSize,
        ),
        child: Image.network(
          artPiece.image,
          fit: BoxFit.cover,
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          artPiece.liked ? Icons.favorite : Icons.favorite_border,
          color: artPiece.liked ? Colors.red : null,
        ),
        onPressed: onLike,
      ),
      onTap: onTap,
    );
  }
}
