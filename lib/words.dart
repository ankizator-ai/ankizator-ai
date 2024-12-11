import 'dart:convert';

import 'package:http/http.dart' as http;

class WordsPair {
  final String pl;
  final String en;
  const WordsPair ({
    required this.pl,
    required this.en,
  });
  factory WordsPair.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
      'pl': String pl,
      'en': String en,
      } =>
          WordsPair(
            pl: pl,
            en: en,
          ),
      _ => throw const FormatException('Failed to load source.'),
    };
  }
}

class ContextsPair {
 final String pl;
 final String en;
 const ContextsPair ({
   required this.pl,
   required this.en,
 });
}

class WordsWithContexts {
 final WordsPair words;
 final ContextsPair contexts;
 const WordsWithContexts ({
   required this.words,
   required this.contexts,
 });
}

Future<List<WordsPair>> fetchWords(String urlMerula) async {
  var url = Uri.http('138.2.174.202','/api/words');
  var destination = urlMerula;
  var jsonBody = jsonEncode({'source': destination});
  final response = await http.post(url, headers: { 'Content-Type': 'application/json',},
body: jsonBody
  );
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    var decodedBody = utf8.decode(response.bodyBytes);
    var rawWords = jsonDecode(decodedBody) as Map<String, dynamic>;
    //List<WordsPair> words = jsonDecode(rawWords['data']);
    //return words;
    List<WordsPair> sources = [];
    for (var element in rawWords['data']) {
      sources.add(WordsPair.fromJson(element));
    }
    return sources;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load source');
  }
}