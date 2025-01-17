import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class GuardianService {
  final String apiKey;
  static const baseUrl = 'https://content.guardianapis.com';

  GuardianService(this.apiKey);

  Future<List<Article>> getArticles({
    String? section,
    String? query,
    int page = 1,
  }) async {
    final response = await http.get(Uri.parse(
      '$baseUrl/search'
      '?api-key=$apiKey'
      '&section=${section ?? ''}'
      '&q=${query ?? ''}'
      '&page=$page'
      '&show-fields=all'
    ));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['response']['results'] as List)
          .map((article) => Article.fromGuardian(article))
          .toList();
    }
    throw Exception('Failed to load news');
  }
} 