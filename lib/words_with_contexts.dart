import 'dart:convert';

import 'package:ankizator_ai/words.dart';
//import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ContextsPair {
 final String pl;
 final String en;
 const ContextsPair ({
   required this.pl,
   required this.en,
 });
 factory ContextsPair.fromJson(Map<String, dynamic> json) {
   return switch (json) {
     {
     'pl': String pl,
     'en': String en,
     } =>
         ContextsPair(
           pl: pl,
           en: en,
         ),
     _ => throw const FormatException('Failed to load contexts.'),
   };
 }
 Map<String, dynamic> toJson() {
   return {
     'pl': pl,
     'en': en,
   };
 }
}

class WordsWithContexts {
 final WordsPair wordsPair;
 final ContextsPair contexts;
 const WordsWithContexts ({
   required this.wordsPair,
   required this.contexts,
 });
 factory WordsWithContexts.fromJson(Map<String, dynamic> json) {
   return switch (json) {
     {
     'wordsPair': Map<String, dynamic> wordsPair,
     'context': Map<String, dynamic> context,
     } =>
         WordsWithContexts(
             wordsPair: WordsPair.fromJson(wordsPair),
              contexts: ContextsPair.fromJson(context),
         ),
     _ => throw const FormatException('Failed to decode words with contexts'),
   };
 }
 Map<String, dynamic> toJson() {
   return {
     'wordsPair': contexts.toJson(),
     'context': wordsPair.toJson(),
   };
 }
}

// TODO: replace extremely bad practise which is sending the whole giant JSON with words
Future<List<WordsWithContexts>> fetchWordsWithContexts(List<WordsPair> words) async {
  var url = Uri.http('138.2.174.202','/api/contexts');
  var jsonBody = jsonEncode({'words': words});
  final response = await http.post(url, headers: { 'Content-Type': 'application/json',},
body: jsonBody
  );
  if (response.statusCode == 200) {
    var decodedBody = utf8.decode(response.bodyBytes);
    var rawExamples = jsonDecode(decodedBody) as List<dynamic>;
    List<Map<String, dynamic>> rawExamplesList = rawExamples
        .map((item) => item as Map<String, dynamic>)
        .toList();
    List<WordsWithContexts> examples = [];
    for (var element in rawExamplesList) {
      examples.add(WordsWithContexts.fromJson(element));
    }
    return examples;
  } else {
    throw Exception('Failed to load words with contexts');
  }
}

class WordsWithContextsRoute extends StatefulWidget {
  final List<WordsPair> words;

  const WordsWithContextsRoute({super.key, required this.words});

  @override
  State<WordsWithContextsRoute> createState() => _WordsWithContextsRoute();
}

class _WordsWithContextsRoute extends State<WordsWithContextsRoute> {
  late Future<List<WordsWithContexts>> futureExamples;

  @override
  void initState() {
    futureExamples = fetchWordsWithContexts(widget.words);
    super.initState();
  }

  _moveToDownload()  async {
    // TODO: finish it later
    print("asd");
    //final directoryPath = await FilePicker.platform.getDirectoryPath();
    //if (directoryPath != null) {
    //  print(directoryPath);
    //} else {
    //  // User canceled the picker
    //}
    //Navigator.push(
    //  context,
    //  MaterialPageRoute(
    //
    //    builder: (context) => const RequestedFile(),
    //  ),
    //);
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
                  Navigator.pop(context);
                }
            ),
          ),

          floatingActionButton: FloatingActionButton(onPressed: _moveToDownload,
            tooltip: 'Generate contexts', child: const Icon(Icons.file_download),),
          body: ListView(
              children: [
                Center(
                  child: FutureBuilder<List<WordsWithContexts>>(
                    future: futureExamples,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return SingleChildScrollView(
                            child: WordsWithContextsTable(wordsWithContexts: snapshot.data!));
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

class WordsWithContextsTable extends StatelessWidget {
  final List<WordsWithContexts> wordsWithContexts;

  const WordsWithContextsTable ({super.key, required this.wordsWithContexts});

  @override
  Widget build(BuildContext context) {
    return Table(
        border: TableBorder.all(),
        columnWidths: const <int, TableColumnWidth>{
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1),
          3: FlexColumnWidth(1),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: wordsWithContexts.map((example) {
          return TableRow(
            children: [
              TableCell(
                  verticalAlignment: TableCellVerticalAlignment.top,
                  child: Text(example.wordsPair.pl)
              ),
              TableCell(
                  verticalAlignment: TableCellVerticalAlignment.top,
                  child: Text(example.wordsPair.en)
              ),
              TableCell(
                  verticalAlignment: TableCellVerticalAlignment.top,
                  child: Text(example.contexts.pl)
              ),
              TableCell(
                  verticalAlignment: TableCellVerticalAlignment.top,
                  child: Text(example.contexts.en)
              )
            ],
          );
        }).toList()
    );
  }
}

