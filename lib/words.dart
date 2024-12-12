import 'dart:convert';

import 'package:http/http.dart' as http;

class WordsPair {
  final String pl;
  final String en;
  bool chosen = false;
  WordsPair ({
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
      _ => throw const FormatException('Failed to decode words'),
    };
  }
  Map<String, dynamic> toJson() {
    return {
      'pl': pl,
      'en': en,
    };
  }
}

Future<List<WordsPair>> fetchWords(String urlMerula) async {
  var url = Uri.http('138.2.174.202','/api/words');
  var destination = urlMerula;
  var jsonBody = jsonEncode({'source': destination});
  final response = await http.post(url, headers: { 'Content-Type': 'application/json',},
body: jsonBody
  );
  if (response.statusCode == 200) {
    var decodedBody = utf8.decode(response.bodyBytes);
    var rawWords = jsonDecode(decodedBody) as Map<String, dynamic>;
    List<WordsPair> sources = [];
    for (var element in rawWords['data']) {
      sources.add(WordsPair.fromJson(element));
    }
    return sources;
  } else {
    throw Exception('Failed to load words');
  }
}