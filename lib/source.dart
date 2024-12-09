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
  var url = Uri.http('10.0.2.2:8000','/api/sources');
  //var destination = 'https://merula.pl/jezyk-angielski/repetytorium-jednotomowe-pr-rozdzial-1-czlowiek-tabela-slow/';
  //var jsonBody = jsonEncode({'source': destination});
  final response = await http.get(url,
    //    headers: {
    //  'Content-Type': 'application/json',
    //},
    //body: jsonBody
  );
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    var rawSources = jsonDecode(response.body) as Map<String, dynamic>;
    List<Source> sources = [];
    for (var element in rawSources['data']) {
      sources.add(Source.fromJson(element));
    }
    return sources;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load source');
  }
}