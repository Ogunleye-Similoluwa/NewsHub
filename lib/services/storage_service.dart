import 'package:news_api_flutter_package/model/article.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const String articlesKey = 'cached_articles';
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> cacheArticles(List<Article> articles) async {
    final articlesJson = articles.map((article) => {
      'source': {
        'id': article.source.id,
        'name': article.source.name,
        'description': article.source.description,
        'url': article.source.url,
        'category': article.source.category,
        'language': article.source.language,
        'country': article.source.country,
      },
      'author': article.author,
      'title': article.title,
      'description': article.description,
      'url': article.url,
      'urlToImage': article.urlToImage,
      'publishedAt': article.publishedAt,
      'content': article.content,
    }).toList();
    await _prefs.setStringList(articlesKey, articlesJson.map((a) => jsonEncode(a)).toList());
  }

  List<Article> getCachedArticles() {
    try {
      final articlesJson = _prefs.getStringList(articlesKey) ?? [];
      return articlesJson.map((json) => Article.fromJson(jsonDecode(json))).toList();
    } catch (e) {
      print('Error loading cached articles: $e');
      return [];
    }
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