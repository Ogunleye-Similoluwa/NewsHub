import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/article.dart';

class StorageService {
  static const String articlesKey = 'cached_articles';
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> cacheArticles(List<Article> articles) async {
    final articlesJson = articles.map((article) => jsonEncode({
      'title': article.title,
      'description': article.description,
      'url': article.url,
      'urlToImage': article.urlToImage,
      'publishedAt': article.publishedAt?.toIso8601String(),
      'content': article.content,
      'author': article.author,
      'source': {
        'name': article.source?.name,
      },
    })).toList();
    await _prefs.setStringList(articlesKey, articlesJson);
  }

  List<Article> getCachedArticles() {
    final articlesJson = _prefs.getStringList(articlesKey) ?? [];
    return articlesJson.map((json) => Article.fromJson(jsonDecode(json))).toList();
  }

  Future<void> savePreference(String key, dynamic value) async {
    if (value is String) await _prefs.setString(key, value);
    if (value is bool) await _prefs.setBool(key, value);
    if (value is int) await _prefs.setInt(key, value);
  }

  dynamic getPreference(String key) {
    return _prefs.get(key);
  }
} 