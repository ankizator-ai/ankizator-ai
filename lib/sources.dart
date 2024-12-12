import 'dart:convert';
import 'package:http/http.dart' as http;
class Source {
  final int id;
  final String name;
  final String url;
  const Source({
    required this.id,
    required this.name,
    required this.url,
  });
  factory Source.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
      'id': int id,
      'name': String name,
      'url': String url,
      } =>
          Source(
            id: id,
            name: name,
            url: url,
          ),
      _ => throw const FormatException('Failed to load source.'),
    };
  }
}
Future<List<Source>> fetchAlbum() async {
  var url = Uri.http('138.2.174.202','/api/sources');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    var decodedBody = utf8.decode(response.bodyBytes);
    var rawSources = jsonDecode(decodedBody) as Map<String, dynamic>;
    List<Source> sources = [];
    for (var element in rawSources['data']) {
      sources.add(Source.fromJson(element));
    }
    return sources;
  } else {
    throw Exception('Failed to load source');
  }
}