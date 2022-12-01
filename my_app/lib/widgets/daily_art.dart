// import 'dart:developer';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

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
  dynamic notificationOptions = {
    "minutely": {"cron": "0 * * * *", "selected": false},
    "hourly": {"cron": "0 * * * *", "selected": false},
    "daily": {"cron": "0 0 * * *", "selected": false},
    "weekly": {"cron": "0 0 * * 0", "selected": false},
    "never": {"cron": null, "selected": true},
  };
  final _liked = <ArtPiece>[];
  final searchController = TextEditingController();
  final usernameController = TextEditingController();

  // create async function to update the _liked list into hive box
  Future<void> _updateLiked() async {
    final directory = await getApplicationDocumentsDirectory();
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ArtPieceAdapter());
    Hive.init("${directory.path}/storage");
    final likedBox = await Hive.openBox('liked');
    likedBox.clear();
    for (var artPiece in _liked) {
      likedBox.add(artPiece);
    }
    return;
  }

  // create async function to update the _user into hive box
  Future<void> _updateUser() async {
    final directory = await getApplicationDocumentsDirectory();
    Hive.init("${directory.path}/storage");
    final userBox = await Hive.openBox('user');
    userBox.clear();
    userBox.add(_user);
    return;
  }

  // create async function to update notificationOptions into hive box
  Future<void> _updateNotificationOptions() async {
    final directory = await getApplicationDocumentsDirectory();
    Hive.init("${directory.path}/storage");
    final notificationOptionsBox = await Hive.openBox('notificationOptions');
    notificationOptionsBox.clear();
    notificationOptionsBox.add(notificationOptions);
    return;
  }

  // create async function to retrieve user name and liked art pieces from hive box
  Future<void> _retrieveInitialData() async {
    final directory = await getApplicationDocumentsDirectory();
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ArtPieceAdapter());
    Hive.init("${directory.path}/storage");
    final userBox = await Hive.openBox('user');
    final likedBox = await Hive.openBox('liked');
    final notificationOptionsBox = await Hive.openBox('notificationOptions');
    if (userBox.isNotEmpty) {
      _user = userBox.getAt(0);
    }
    if (likedBox.isNotEmpty) {
      for (var artPiece in likedBox.values) {
        _liked.add(artPiece);
      }
    }
    if (notificationOptionsBox.isNotEmpty) {
      notificationOptions = notificationOptionsBox.getAt(0);
    }
    return;
  }

  void _pushSettings() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return Scaffold(
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
                  backgroundImage: NetworkImage('https://picsum.photos/400'),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(16),
                // align text field in center
                child: TextField(
                  onChanged: (value) => setState(() {
                    _user = value;
                    _updateUser();
                  }),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  controller: usernameController..text = _user,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      suffixIcon: Icon(Icons.edit),
                      border: OutlineInputBorder(),
                      labelText: 'Username'),
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
              // when a button is pressed the 'selected' property of the corresponding option is set to true
              // and the 'selected' property of the other options is set to false
              // the 'selected' property is used to display the button with a different color and visible text
              // the 'never' option is selected by default

              Container(
                margin: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    for (var option in notificationOptions.entries)
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                for (var otherOption
                                    in notificationOptions.entries) {
                                  if (otherOption.key == option.key) {
                                    otherOption.value["selected"] = true;
                                  } else {
                                    otherOption.value["selected"] = false;
                                  }
                                }
                                _updateNotificationOptions();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: option.value["selected"]
                                  ? Colors.blue
                                  : Colors.white,
                              foregroundColor: option.value["selected"]
                                  ? Colors.white
                                  : Colors.black,
                              side: option.value["selected"]
                                  ? null
                                  : const BorderSide(
                                      color: Colors.grey, width: 1),
                            ),
                            child: Text(option.key),
                          ),
                        ),
                      ),
                  ],
                ),
              )
            ],
          ),
        );
      });
    }));
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

  void _likeArtPiece(ArtPiece artPiece, StateSetter setState) async {
    setState(() {
      if (_liked.contains(artPiece)) {
        _liked.remove(artPiece);
      } else {
        _liked.add(artPiece);
      }
      _updateLiked();
    });
  }

  void _pushSaved() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          final tiles = _liked.map(
            (artPiece) {
              return ArtPieceRow.buildRow(
                  artPiece,
                  true,
                  () => _pushArtPieceDetails(artPiece),
                  () => _likeArtPiece(artPiece, setState));
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
      );
    }));
  }

  Future startApp() async {
    await _retrieveInitialData();
    return getArtPiecesData(_query);
  }

  Future getArtPiecesData(String query) async {
    List<ArtPiece> artPieces = [];

    var limit = 12;
    var count = 0;

    var url = Uri.parse(
        'https://collectionapi.metmuseum.org/public/collection/v1/search?medium=Paintings&hasImages=true&q="$query"');
    var response = await http.get(url);
    var jsonData = json.decode(response.body);

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
            controller: searchController,
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
                  future: startApp(),
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
                              () => _likeArtPiece(artPiece, setState));
                        },
                      );
                    }
                  }))
        ]));
  }
}
