import 'package:ankizator_ai/sources.dart';
import 'package:ankizator_ai/words.dart';
import 'package:ankizator_ai/words_with_contexts.dart';
import 'package:flutter/material.dart';

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
                              builder: (context) => WordsRoute(urlMerula: doc.url), // Replace with your screen
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
                                              "https://merula.pl/kos/wp-content/uploads/2014/10/merula_logo4@2x.png")

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
  final String urlMerula;

  const WordsRoute({super.key, required this.urlMerula});

  @override
  State<WordsRoute> createState() => _WordsRoute();
}

class _WordsRoute extends State<WordsRoute> {
  late Future<List<WordsPair>> futureWords;

  @override
  void initState() {
    super.initState();
    futureWords = fetchWords(widget.urlMerula);
  }

  _moveToDownload() async {
    //TODO: TWOJA MAMA
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
        builder: (context) => WordsWithContextsRoute(words: chosenWords),
      ),
    );
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

        floatingActionButton: FloatingActionButton(
          onPressed: _moveToDownload,
          tooltip: 'Generate contexts', child: const Icon(Icons.add),),
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
        )
      ),
    );
  }
}

class WordsTable extends StatelessWidget {
  final List<WordsPair> words;

  const WordsTable ({super.key, required this.words});

  @override
  Widget build(BuildContext context) {

    return Table(
        border: TableBorder.all(),
        columnWidths: const <int, TableColumnWidth>{
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(3),
          2: FlexColumnWidth(3),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: words.map((wordsPair) {
          return TableRow(
            children: [
                TableCell(
                    verticalAlignment: TableCellVerticalAlignment.top,
                    child: CheckBoxWidget(wordsPair: wordsPair)
                ),
                TableCell(
                    verticalAlignment: TableCellVerticalAlignment.top,
                    child: Text(wordsPair.pl)
                ),
                TableCell(
                    verticalAlignment: TableCellVerticalAlignment.top,
                    child: Text(wordsPair.en)
                )
            ],
          );
        }).toList()
    );
  }
}

class CheckBoxWidget extends StatefulWidget {
  final WordsPair wordsPair;

  const CheckBoxWidget ({super.key, required this.wordsPair});

  @override
  State<CheckBoxWidget> createState() => _CheckBoxState();
}

class _CheckBoxState extends State<CheckBoxWidget>{
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: isChecked,
      onChanged: (bool? value) {
        setState(() {
          isChecked = value!;
          widget.wordsPair.chosen = value;
        });
      },
    );
  }
}


