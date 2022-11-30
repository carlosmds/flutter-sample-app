import 'package:flutter/material.dart';

import '../model/art_piece.dart';

class ArtPieceRow {
  static const _biggerFont =
      TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  static const _artImageBoxMinSize = 44.0;
  static const _artImageBoxMaxSize = 64.0;

  static ListTile buildRow(
      ArtPiece artPiece, bool liked, VoidCallback onTap, VoidCallback onLike) {
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
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          liked ? Icons.favorite : Icons.favorite_border,
          color: liked ? Colors.red : null,
        ),
        onPressed: onLike,
      ),
      onTap: onTap,
    );
  }
}
