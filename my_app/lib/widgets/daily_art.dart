import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/widgets/art_piece_row.dart';
import 'dart:convert';

import '../model/art_piece.dart';

class DailyArt extends StatefulWidget {
  const DailyArt({super.key});

  @override
  State<DailyArt> createState() => _DailyArtState();
}

class _DailyArtState extends State<DailyArt> {
  String _query = "Leonardo da Vinci";
  String _user = "Artsy User";
  Map<String, String?> _notification_options = {
    "daily": "* * * * *",
    "weekly": "* * * * *",
    "monthly": "* * * * *",
    "never": null
  };
  final _liked = <ArtPiece>[];
  final controller = TextEditingController();

  void _pushSettings() {
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (context) => Scaffold(
              appBar: AppBar(
                title: const Text('Settings'),
              ),
              body: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(64),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          NetworkImage('https://picsum.photos/400'),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(16),
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Username',
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(16),
                    child: Text(
                      'Notification Frequency',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  // display the notification options in separate buttons that keeps selection when pressed
                  // the buttons are displayed one in top of the other with the same size
                  Column(
                    children: _notification_options.keys.map((String key) {
                      return Container(
                        margin: const EdgeInsets.all(16),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: _notification_options[key] != null
                                  ? Colors.blue
                                  : Colors.grey,
                              onPrimary: Colors.white,
                              minimumSize: const Size(200, 50),
                            ),
                            onPressed: () {
                              setState(() {
                                _notification_options[key] = "* * * * *";
                                _notification_options.forEach((k, v) {
                                  if (k != key) {
                                    _notification_options[k] = null;
                                  }
                                });
                              });
                            },
                            child: Text(key)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            )));
  }

  void _pushArtPieceDetails(ArtPiece artPiece) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text(artPiece.title),
        ),
        body: Center(
          child: Column(
            children: [
              Image.network(
                artPiece.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error),
              ),
              Text(artPiece.title),
              Text(artPiece.description),
            ],
          ),
        ),
      ),
    ));
  }

  void _likeArtPiece(ArtPiece artPiece) {
    setState(() {
      if (_liked.contains(artPiece)) {
        _liked.remove(artPiece);
      } else {
        _liked.add(artPiece);
      }
    });
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          final tiles = _liked.map(
            (artPiece) {
              return ArtPieceRow.buildRow(
                  artPiece,
                  true,
                  () => _pushArtPieceDetails(artPiece),
                  () => _likeArtPiece(artPiece));
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

  Future getArtPiecesData(String query) async {
    List<ArtPiece> artPieces = [];

    var limit = 12;
    var count = 0;

    var url = Uri.parse(
        'https://collectionapi.metmuseum.org/public/collection/v1/search?medium=Paintings&hasImages=true&q="$query"');
    var response = await http.get(url);
    var jsonData = json.decode(response.body);

    print(jsonData);

    if (jsonData['total'] == 0) {
      return artPieces;
    }

    for (var artPieceID in jsonData['objectIDs']) {
      var url = Uri.parse(
          'https://collectionapi.metmuseum.org/public/collection/v1/objects/$artPieceID');
      var response = await http.get(url);

      var artPieceData = json.decode(response.body);

      if (artPieceData['objectID'] == null ||
          artPieceData['primaryImage'] == "") {
        continue;
      }

      ArtPiece artPiece = ArtPiece(
          id: artPieceData['objectID'],
          title: artPieceData['title'],
          image: artPieceData['primaryImage'],
          description: artPieceData['objectName'],
          data: artPieceData);

      artPieces.add(artPiece);

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
        body: Column(children: <Widget>[
          TextField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search for art pieces',
              border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(2.0)),
            ),
            onChanged: (value) {
              setState(() {
                _query = value;
              });
            },
          ),
          Expanded(
              child: FutureBuilder(
                  future: getArtPiecesData(_query),
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      return const Center(
                        child: Text('Loading...'),
                      );
                    } else {
                      var artPieces = snapshot.data! as List<ArtPiece>;

                      return ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: ((artPieces.length) * 2),
                        itemBuilder: (context, i) {
                          if (i.isOdd) return const Divider();

                          final index = i ~/ 2;

                          var artPiece = artPieces[index];

                          return ArtPieceRow.buildRow(
                              artPiece,
                              _liked.contains(artPiece),
                              () => _pushArtPieceDetails(artPiece),
                              () => _likeArtPiece(artPiece));
                        },
                      );
                    }
                  }))
        ]));
  }
}
