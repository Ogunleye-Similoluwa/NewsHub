import 'dart:convert';
import 'package:http/http.dart' as http;
import 'article.dart';

class NewsAPI {
  final String apiKey;
  static const String baseUrl = 'https://newsapi.org/v2';

  NewsAPI({required this.apiKey});

  Future<List<Article>> getTopHeadlines({
    required String category,
    required String country,
    int page = 1,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/top-headlines'
          '?apiKey=$apiKey'
          '&category=$category'
          '&country=$country'
          '&page=$page'
          '&pageSize=20'
        ),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'X-Api-Key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          return (data['articles'] as List)
              .map((article) => Article.fromJson(article))
              .toList();
        }
      }
      print('NewsAPI Error: ${response.body}');
      throw Exception('Failed to load news');
    } catch (e) {
      print('NewsAPI Error: $e');
      throw Exception('Failed to load news');
    }
  }

  Future<List<Article>> getEverything({
    String? query,
    int pageSize = 50,
  }) async {
    final response = await http.get(Uri.parse(
      '$baseUrl/everything?'
      '${query != null ? 'q=$query&' : ''}'
      'pageSize=$pageSize'
      '&apiKey=$apiKey'
    ));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final articles = (json['articles'] as List)
          .map((article) => Article.fromJson(article))
          .toList();
      return articles;
    }
    throw Exception('Failed to load news');
  }
} 