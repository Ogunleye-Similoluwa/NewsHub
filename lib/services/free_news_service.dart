import 'dart:convert';

import 'package:news_api_flutter_package/model/article.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'combined_news_service.dart';

class FreeNewsService {
  final CombinedNewsService _combinedService;
  final SharedPreferences _prefs;

  FreeNewsService._(this._combinedService, this._prefs);

  static Future<FreeNewsService> create(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    final combinedService = await CombinedNewsService.create(apiKey);
    return FreeNewsService._(combinedService, prefs);
  }

  Future<List<Article>> getNews() async {
    return _combinedService.getNews(
      category: 'general',
      country: 'us',
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