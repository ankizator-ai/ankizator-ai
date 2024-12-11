import 'package:ankizator_ai/words.dart';
import 'package:flutter/material.dart';

void main() => runApp(const WordsRoute());
class WordsRoute extends StatefulWidget {
  const WordsRoute({super.key});
  @override
  State<WordsRoute> createState() => _WordsRoute();
}

class _WordsRoute extends State<WordsRoute> {
  late Future<List<WordsPair>> futureWords;
  @override
  void initState() {
    super.initState();
    futureWords = fetchWords();
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
          title: const Text('Fetch Data Example'),
        ),
        body: Center(
          child: FutureBuilder<List<WordsPair>>(
            future: futureWords,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SingleChildScrollView(child: WordsTable(words: snapshot.data!));
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

class WordsTable extends StatelessWidget {
  final List<WordsPair> words;

  const WordsTable ({super.key, required this.words});

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(),
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
        2: FixedColumnWidth(64),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: words.map((wordsPair) {
        return TableRow(children: [
          TableCell(
              verticalAlignment: TableCellVerticalAlignment.top,
              child: Text(wordsPair.pl)
            ),
          TableCell(
              verticalAlignment: TableCellVerticalAlignment.top,
              child: Text(wordsPair.en)
          ),
          ],
        );
      }).toList()
    );
  }
}
