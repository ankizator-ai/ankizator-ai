import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ankizator_ai/main.dart';
import 'package:ankizator_ai/words.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

class ContextsPair {
 final int id;
 final String og;
 final String tr;
 const ContextsPair ({
   required this.id,
   required this.og,
   required this.tr,
 });
 factory ContextsPair.fromJson(Map<String, dynamic> json) {
   return switch (json) {
     {
     'id': int id,
     'og': String og,
     'tr': String tr,
     } =>
         ContextsPair(
           id: id,
           og: og,
           tr: tr,
         ),
     _ => throw const FormatException('Failed to load contexts.'),
   };
 }
 Map<String, dynamic> toJson() {
   return {
     'id': id,
     'og': og,
     'tr': tr,
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
     'word': Map<String, dynamic> wordsPair,
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
     'word': wordsPair.toJson(),
     'context': contexts.toJson(),
   };
 }
}

Future<List<WordsWithContexts>> fetchWordsWithContexts(int collectionId, List<WordsPair> words) async {
  var url = Uri.http(kBaseUrl,'/api/collections/$collectionId/contexts');
  await http.delete(url);
  var ids = jsonEncode(words.map((w) => w.id).toList());
  final response = await http.post(url, headers: { 'Content-Type': 'application/json'}, body: ids );
  if (response.statusCode == 201) {
    final getAllResponses = await http.get(url);
    if (getAllResponses.statusCode == 200) {
      final List<dynamic> data = jsonDecode(getAllResponses.body);
      data.removeWhere((dat) => !ids.contains(dat['word']['id'].toString()));
      return data.map((item) {
        final word = WordsPair.fromJson(item['word']);
        final context = ContextsPair.fromJson(item['context']);
        return WordsWithContexts(wordsPair: word, contexts: context);
      }).toList();
    } else {
      throw Exception('Failed to fetch generated contexts');
    }
  } else {
    return List.empty();
  }
}

class WordsWithContextsRoute extends StatefulWidget {
  final int collectionId;
  final List<WordsPair> words;

  const WordsWithContextsRoute({super.key, required this.collectionId, required this.words});

  @override
  State<WordsWithContextsRoute> createState() => _WordsWithContextsRoute();
}

class _WordsWithContextsRoute extends State<WordsWithContextsRoute> {
  late Future<List<WordsWithContexts>> futureExamples;

  @override
  void initState() {
    futureExamples = fetchWordsWithContexts(widget.collectionId, widget.words);
    super.initState();
  }
  _moveToDownload() async {
    if (!Platform.isAndroid) {
      print("This method is Android only");
      return null;
    }

    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (status.isGranted) {
        print("Storage permission granted");
      } else if (status.isPermanentlyDenied) {
        openAppSettings(); // allow user to manually enable
      }
    }
    final url = Uri.http(kBaseUrl, "/api/collections/${widget.collectionId}/anki");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (!await downloadsDir.exists()) {
        print("Downloads directory does not exist");
        return null;
      }

      final filePath = "${downloadsDir.path}/collection_${widget.collectionId}.apkg";
      final file = File(filePath);

      await file.writeAsBytes(response.bodyBytes);
      print("File saved to $filePath");
      return filePath;
    } else {
      print("Failed to download file. Status: ${response.statusCode}");
      return null;
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
                  Navigator.pop(context);
                }
            ),
          ),

          floatingActionButton: FutureBuilder<List<WordsWithContexts>>(
            future: futureExamples,
            builder: (context, snapshot) {
              bool isEnabled = snapshot.hasData && snapshot.data!.isNotEmpty;
              return FloatingActionButton(
                onPressed: isEnabled ? () async {
                  final filePath = await _moveToDownload();  // Get the file path back

                  if (filePath != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Download complete: collection_${widget.collectionId}.apkg'),
                        action: SnackBarAction(
                          label: 'OPEN',
                          onPressed: () {
                            OpenFilex.open(filePath);
                          },
                        ),
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                } : null,
                tooltip: 'Generate contexts',
                backgroundColor: isEnabled ? null : Colors.grey,
                child: const Icon(Icons.file_download),
              );
            },
          ),
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
                  child: Text(example.wordsPair.og)
              ),
              TableCell(
                  verticalAlignment: TableCellVerticalAlignment.top,
                  child: Text(example.wordsPair.tr)
              ),
              TableCell(
                  verticalAlignment: TableCellVerticalAlignment.top,
                  child: Text(example.contexts.og)
              ),
              TableCell(
                  verticalAlignment: TableCellVerticalAlignment.top,
                  child: Text(example.contexts.tr)
              )
            ],
          );
        }).toList()
    );
  }
}