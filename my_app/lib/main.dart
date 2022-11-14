// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'DAILY ART!!!',
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
        ),
        home: const DailyArt());
  }
}

class DailyArt extends StatefulWidget {
  const DailyArt({super.key});

  @override
  State<DailyArt> createState() => _DailyArtState();
}

class _DailyArtState extends State<DailyArt> {
  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          final tiles = _saved.map(
            (pair) {
              return ListTile(
                title: Text(
                  pair,
                  style: _biggerFont,
                ),
              );
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

  final _saved = <String>[];
  final _biggerFont = TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    var arts = ["monalisa", "o grito", "noite estrelada"];

    return Scaffold(
        appBar: AppBar(
          title: const Text('Artes diariamente'),
          actions: [
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: _pushSaved,
              tooltip: 'Saved Suggestions',
            ),
          ],
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemBuilder: /*1*/ (context, i) {
            if (i.isOdd) return const Divider();

            final index = i ~/ 2; /*3*/
            if (index >= arts.length) {
              arts.addAll(["random art here"]);
            }

            final alreadySaved = _saved.contains(arts[index]);

            return ListTile(
              title: Text(
                arts[index],
                style: _biggerFont,
              ),
              trailing: Icon(
                alreadySaved ? Icons.favorite : Icons.favorite_border,
                color: alreadySaved ? Colors.red : null,
                semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
              ),
              onTap: () {
                setState(() {
                  if (alreadySaved) {
                    _saved.remove(arts[index]);
                  } else {
                    _saved.add(arts[index]);
                  }
                });
              },
            );
          },
        ));
  }
}
