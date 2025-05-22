import 'dart:convert';

import 'package:ankizator_ai/sources.dart';
import 'package:ankizator_ai/words.dart';
import 'package:ankizator_ai/words_with_contexts.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String kBaseUrl = '192.168.19.115';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Source>> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnkizatorAI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow.shade700),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AnkizatorAI'),
        ),
        body: Center(
          child: FutureBuilder<List<Source>>(
            future: futureAlbum,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return GridView.count(
                    childAspectRatio: 4 / 6,
                    crossAxisCount: 3,
                    children: snapshot.data!.map<Widget>((doc) {
                      return GestureDetector(
                          onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WordsRoute(sourceId: doc.id), // Replace with your screen
                            ),
                          );
                        },
                          child: Center(
                            child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 1,
                                        child: ClipOval(
                                          child: Image.network(
                                              "https://merula.pl/kos/wp-content/uploads/2014/10/merula_logo4@2x.png"
                                          )
                                        ),
                                      ),
                                      Text(doc.name)
                                    ],
                                  ),
                                )
                            ),
                          )
                      );
                    }
                    ).toList()
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}

class WordsRoute extends StatefulWidget {
  final int sourceId;

  const WordsRoute({super.key, required this.sourceId});

  @override
  State<WordsRoute> createState() => _WordsRoute();
}

class _WordsRoute extends State<WordsRoute> {
  late Future<List<WordsPair>> futureWords;

  @override
  void initState() {
    super.initState();
    futureWords = fetchWords(widget.sourceId);
  }

  _moveToDownload() async {
    List<WordsPair> words = await futureWords;
    List<WordsPair> chosenWords = [];

    for(var word in words){
      if(word.chosen){
        chosenWords.add(word);
      }
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WordsWithContextsRoute(key: widget.key, collectionId: widget.sourceId, words: chosenWords),
      ),
    );
  }

  Future<void> _extractWords() async {
    final id = widget.sourceId;

    final extractUrl = Uri.http(kBaseUrl,'/api/collections/$id/extract');
    final wordsUrl = Uri.http(kBaseUrl,'/api/collections/$id/words');

    try {
      final extractResponse = await http.get(extractUrl);

      if (extractResponse.statusCode == 200) {
        final List<dynamic> words = json.decode(extractResponse.body);
        final postResponse = await http.post(wordsUrl, headers: {'Content-Type': 'application/json'}, body: json.encode(words),);

        if (postResponse.statusCode == 200 || postResponse.statusCode == 201) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WordsRoute(key: widget.key, sourceId: widget.sourceId),
            ),
          );

        } else {
          throw Exception('Failed to post words');
        }
      } else {
        throw('Failed to fetch words');
      }
    } catch (e) {
      throw('Error in _extractWords: $e');
    }

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnkizatorAI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow.shade700),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Dictionary'),
          leading: BackButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyApp(),
                  ),
                );
              }
          ),
        ),
        floatingActionButton: FutureBuilder<List<WordsPair>>(
          future: futureWords,
          builder: (context, snapshot) {
            // Only show FAB if we have data and the list is NOT empty
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return FloatingActionButton(
                onPressed: _moveToDownload,
                tooltip: 'Generate contexts',
                child: const Icon(Icons.add),
              );
            } else if(snapshot.hasData) {
              return FloatingActionButton(
                onPressed: _extractWords,
                tooltip: 'Generate words',
                child: const Icon(Icons.find_in_page),
              );
            }
            // Otherwise, return an empty container (no button)
            return Container();
          },
        ),
        body: ListView(
            children: [
              Center(
                child: FutureBuilder<List<WordsPair>>(
                  future: futureWords,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return SingleChildScrollView(
                          child: WordsTable(words: snapshot.data!));
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }
                    return const CircularProgressIndicator();
                    },
                ),
              ),
            ]
        ),
      ),
    );
  }
}

// class WordsTable extends StatelessWidget {
//   final List<WordsPair> words;
//
//   const WordsTable ({super.key, required this.words});
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Table(
//         border: TableBorder.all(),
//         columnWidths: const <int, TableColumnWidth>{
//           0: FlexColumnWidth(1),
//           1: FlexColumnWidth(3),
//           2: FlexColumnWidth(3),
//         },
//         defaultVerticalAlignment: TableCellVerticalAlignment.middle,
//         children: words.map((wordsPair) {
//           return TableRow(
//             children: [
//                 TableCell(
//                     verticalAlignment: TableCellVerticalAlignment.top,
//                     child: CheckBoxWidget(wordsPair: wordsPair)
//                 ),
//                 TableCell(
//                     verticalAlignment: TableCellVerticalAlignment.top,
//                     child: Text(wordsPair.og)
//                 ),
//                 TableCell(
//                     verticalAlignment: TableCellVerticalAlignment.top,
//                     child: Text(wordsPair.tr)
//                 )
//             ],
//           );
//         }).toList()
//     );
//   }
// }
//
// class CheckBoxWidget extends StatefulWidget {
//   final WordsPair wordsPair;
//
//   const CheckBoxWidget ({super.key, required this.wordsPair});
//
//   @override
//   State<CheckBoxWidget> createState() => _CheckBoxState();
// }
//
// class _CheckBoxState extends State<CheckBoxWidget>{
//   bool isChecked = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Checkbox(
//       value: isChecked,
//       onChanged: (bool? value) {
//         setState(() {
//           isChecked = value!;
//           widget.wordsPair.chosen = value;
//         });
//       },
//     );
//   }
// }
//


class WordsTable extends StatefulWidget {
  final List<WordsPair> words;

  const WordsTable({super.key, required this.words});

  @override
  State<WordsTable> createState() => _WordsTableState();
}

class _WordsTableState extends State<WordsTable> {
  bool masterChecked = false;

  void toggleAll(bool? value) {
    if (value == null) return;
    setState(() {
      masterChecked = value;
      for (var wp in widget.words) {
        wp.chosen = masterChecked;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: masterChecked,
              onChanged: toggleAll,
            ),
            const Text('Check All'),
          ],
        ),
        Table(
          border: TableBorder.all(),
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(3),
            2: FlexColumnWidth(3),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: widget.words.map((wordsPair) {
            return TableRow(
              children: [
                TableCell(
                    verticalAlignment: TableCellVerticalAlignment.top,
                    child: CheckBoxWidget(wordsPair: wordsPair, onChanged: () {
                      setState(() {}); // rebuild parent when checkbox changes
                    })
                ),
                TableCell(
                    verticalAlignment: TableCellVerticalAlignment.top,
                    child: Text(wordsPair.og)
                ),
                TableCell(
                    verticalAlignment: TableCellVerticalAlignment.top,
                    child: Text(wordsPair.tr)
                )
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class CheckBoxWidget extends StatefulWidget {
  final WordsPair wordsPair;
  final VoidCallback onChanged;  // callback to notify parent to rebuild

  const CheckBoxWidget({
    super.key,
    required this.wordsPair,
    required this.onChanged,
  });

  @override
  State<CheckBoxWidget> createState() => _CheckBoxState();
}

class _CheckBoxState extends State<CheckBoxWidget> {
  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: widget.wordsPair.chosen,
      onChanged: (bool? value) {
        setState(() {
          widget.wordsPair.chosen = value!;
        });
        widget.onChanged();
      },
    );
  }
}
