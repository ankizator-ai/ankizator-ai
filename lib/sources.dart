import 'dart:convert';
import 'package:ankizator_ai/main.dart';
import 'package:http/http.dart' as http;
class Source {
  final int id;
  final String name;
  const Source({
    required this.id,
    required this.name
  });
  factory Source.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
      'id': int id,
      'name': String name
      } =>
          Source(
            id: id,
            name: name
          ),
      _ => throw const FormatException('Failed to load source.'),
    };
  }
}
Future<List<Source>> fetchAlbum() async {
  var url = Uri.http(kBaseUrl,'/api/collections');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    var decodedBody = utf8.decode(response.bodyBytes);
    var rawSources = jsonDecode(decodedBody) as List<dynamic>;
    List<Source> sources = [];
    for (var element in rawSources) {
      sources.add(Source.fromJson(element));
    }
    return sources;
  } else {
    throw Exception('Failed to load source');
  }
}