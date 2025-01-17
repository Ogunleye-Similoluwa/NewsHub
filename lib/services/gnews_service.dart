import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class GNewsService {
  final String apiKey;
  static const baseUrl = 'https://gnews.io/api/v4';

  GNewsService(this.apiKey);

  Future<List<Article>> getTopNews({
    String? category,
    String? country,
    int page = 1,
  }) async {
    final response = await http.get(Uri.parse(
      '$baseUrl/top-headlines'
      '?token=$apiKey'
      '&category=${category ?? ''}'
      '&country=${country ?? ''}'
      '&page=$page'
    ));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['articles'] as List)
          .map((article) => Article.fromGNews(article))
          .toList();
    }
    throw Exception('Failed to load news');
  }
} 