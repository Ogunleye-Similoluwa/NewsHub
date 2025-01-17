import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/model/source.dart';


class WikipediaService {
  Future<List<Article>> getCurrentEvents() async {
    final response = await http.get(
      Uri.parse('https://en.wikipedia.org/api/rest_v1/feed/onthisday/events/${DateTime.now().month}/${DateTime.now().day}')
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['events'] as List).map((event) {
        final page = event['pages']?[0];
        final source = Source(
          'wikipedia',
         'Wikipedia',
          'Wikipedia Events',
          'https://wikipedia.org',
          'general',
         'en',
          'us'
        );
        return Article(
          source,
          'Wikipedia',
          event['text'],
          page?['extract'],
          'https://en.wikipedia.org/wiki/${page?['title']}',
          page?['thumbnail']?['source'],
          DateTime.now().toIso8601String(),
          page?['extract']
        );
      }).toList();
    }
    throw Exception('Failed to load events');
  }
} 