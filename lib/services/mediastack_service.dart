import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class MediastackService {
  final String apiKey;
  static const baseUrl = 'http://api.mediastack.com/v1';

  MediastackService(this.apiKey);

  Future<List<Article>> getNews({
    String? category,
    String? country,
    int offset = 0,
  }) async {
    final response = await http.get(Uri.parse(
      '$baseUrl/news'
      '?access_key=$apiKey'
      '&categories=${category ?? ''}'
      '&countries=${country ?? ''}'
      '&offset=$offset'
    ));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List)
          .map((article) => Article.fromMediastack(article))
          .toList();
    }
    throw Exception('Failed to load news');
  }
} 