import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/article.dart';

class WikipediaService {
  Future<List<Article>> getCurrentEvents() async {
    final response = await http.get(
      Uri.parse('https://en.wikipedia.org/api/rest_v1/feed/onthisday/events/${DateTime.now().month}/${DateTime.now().day}')
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['events'] as List).map((event) {
        final page = event['pages']?[0];
        return Article(
          title: event['text'],
          description: page?['extract'],
          url: 'https://en.wikipedia.org/wiki/${page?['title']}',
          urlToImage: page?['thumbnail']?['source'],
          publishedAt: DateTime.now(),
          source: Source(name: 'Wikipedia'),
        );
      }).toList();
    }
    throw Exception('Failed to load events');
  }
} 