import 'dart:convert';
import 'package:ankizator_ai/main.dart';
import 'package:http/http.dart' as http;

class WordsPair {
  final int id;
  final String og;
  final String tr;
  bool chosen = false;
  WordsPair ({
    required this.id,
    required this.og,
    required this.tr,
  });
  factory WordsPair.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
      'id': int id,
      'og': String og,
      'tr': String tr,
      } =>
          WordsPair(
            id: id,
            og: og,
            tr: tr,
          ),
      _ => throw const FormatException('Failed to decode words'),
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

Future<List<WordsPair>> fetchWords(int sourceId) async {
  var url = Uri.http(kBaseUrl, '/api/collections/$sourceId/words');
  final response = await http.get(url); // Changed POST to GET, unless your API expects POST

  if (response.statusCode == 200) {
    var decodedBody = utf8.decode(response.bodyBytes);
    var rawWords = jsonDecode(decodedBody) as List<dynamic>;
    List<WordsPair> words = rawWords.map((e) => WordsPair.fromJson(e)).toList();
    return words;
  } else {
    throw Exception('Failed to load words');
  }
}

