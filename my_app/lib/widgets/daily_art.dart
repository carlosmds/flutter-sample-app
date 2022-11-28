import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/widgets/art_item_row.dart';
import 'dart:convert';

import '../model/art_piece.dart';

class DailyArt extends StatefulWidget {
  const DailyArt({super.key});

  @override
  State<DailyArt> createState() => _DailyArtState();
}

class _DailyArtState extends State<DailyArt> {
  final _liked = <ArtPiece>[];

  void _pushSettings() {}

  void _pushSaved() {
    print('teste');
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          final tiles = _liked.map(
            (artPiece) {
              return ArtItemRow.buildRow(
                  artPiece,
                  () => setState(() {
                        artPiece.toggleLiked();
                        if (artPiece.liked) {
                          _liked.remove(artPiece);
                        } else {
                          _liked.add(artPiece);
                        }
                      }),
                  (() => setState(() {
                        artPiece.toggleLiked();
                        if (artPiece.liked) {
                          _liked.remove(artPiece);
                        } else {
                          _liked.add(artPiece);
                        }
                      })));
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
                  context: context,
                  tiles: tiles,
                ).toList()
              : <Widget>[];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }

  Future getArtPiecesData() async {
    List<Map<int, ArtPiece>> artPieces = [];

    var limit = 3;
    var count = 0;

    var url = Uri.parse(
        'https://collectionapi.metmuseum.org/public/collection/v1/search?medium=Paintings&hasImages=true&q=van-gogh');
    var response = await http.get(url);
    var jsonData = json.decode(response.body);

    for (var artPieceID in jsonData['objectIDs']) {
      var url = Uri.parse(
          'https://collectionapi.metmuseum.org/public/collection/v1/objects/$artPieceID');
      var response = await http.get(url);

      var artPieceData = json.decode(response.body);

      ArtPiece artPiece = ArtPiece(
          id: artPieceData['objectID'],
          title: artPieceData['title'],
          image: artPieceData['primaryImage'],
          description: artPieceData['objectName'],
          liked: _liked.contains(artPieceData),
          data: artPieceData);

      artPieces.add({artPiece.id: artPiece});

      count++;

      if (count == limit) {
        break;
      }
    }
    return artPieces;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Daily Art.'),
          leading: IconButton(
            alignment: Alignment.centerLeft,
            icon: const Icon(Icons.settings),
            onPressed: _pushSettings,
            tooltip: 'Settings',
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: _pushSaved,
              tooltip: 'Saved Suggestions',
            ),
          ],
        ),
        body: FutureBuilder(
            future: getArtPiecesData(),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return const Center(
                  child: Text('Loading...'),
                );
              } else {
                var artPieces = snapshot.data! as List<Map<int, ArtPiece>>;

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: ((artPieces.length) * 2),
                  itemBuilder: (context, i) {
                    if (i.isOdd) return const Divider();

                    final index = i ~/ 2;

                    print(artPieces);
                    print(index);
                    print(artPieces[index]);

                    var artItem = artPieces[index].values.first;

                    return ArtItemRow.buildRow(
                        artItem,
                        () => setState(() {
                              artItem.toggleLiked();
                              if (artItem.liked) {
                                _liked.remove(artItem);
                              } else {
                                _liked.add(artItem);
                              }
                            }),
                        (() => setState(() {
                              artItem.toggleLiked();
                              if (artItem.liked) {
                                _liked.remove(artItem);
                              } else {
                                _liked.add(artItem);
                              }
                            })));
                  },
                );
              }
            }));
  }
}
