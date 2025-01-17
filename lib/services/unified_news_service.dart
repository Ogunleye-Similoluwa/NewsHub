import 'package:news_api_flutter_package/model/article.dart';

import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'mediastack_service.dart';
import 'gnews_service.dart';
import 'guardian_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UnifiedNewsService {
  final NewsAPI primaryService;
  final SharedPreferences _prefs;

  UnifiedNewsService._({
    required this.primaryService,
    required SharedPreferences prefs,
  }) : _prefs = prefs;

  static Future<UnifiedNewsService> create({
    required NewsAPI primaryService,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return UnifiedNewsService._(
      primaryService: primaryService,
      prefs: prefs,
    );
  }

  Future<List<Object>> getNews({
    required String category,
    required String country,
    int page = 1,
  }) async {
    return await primaryService.getTopHeadlines(
      category: category,
      country: country,
      page: page,
    );
  }

  Future<List<Article>> getSavedArticles() async {
    List<String> savedUrls = _prefs.getStringList('savedArticles') ?? [];
    List<Article> articles = [];
    for (String url in savedUrls) {
      String? json = _prefs.getString(url);
      if (json != null) {
        articles.add(Article.fromJson(jsonDecode(json)));
      }
    }
    return articles;
  }

  Future<void> saveArticle(Article article) async {
    List<String> savedUrls = _prefs.getStringList('savedArticles') ?? [];
    if (!savedUrls.contains(article.url)) {
      savedUrls.add(article.url!);
      await _prefs.setStringList('savedArticles', savedUrls);
      await _prefs.setString(article.url!, jsonEncode(article));
    }
  }

  Future<void> removeArticle(Article article) async {
    List<String> savedUrls = _prefs.getStringList('savedArticles') ?? [];
    savedUrls.remove(article.url);
    await _prefs.setStringList('savedArticles', savedUrls);
    await _prefs.remove(article.url!);
  }
} 