import 'package:news_reader/models/article.dart';
import 'package:news_reader/services/reddit_service.dart';
import 'package:news_reader/services/rss_service.dart';
import 'package:news_reader/services/wikipedia_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FreeNewsService {
  final RSSService _rssService = RSSService();
  final RedditService _redditService = RedditService();
  final WikipediaService _wikiService = WikipediaService();
  final SharedPreferences _prefs;

  FreeNewsService._(this._prefs);

  static Future<FreeNewsService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return FreeNewsService._(prefs);
  }

  Future<List<Article>> getNews() async {
    List<Article> allArticles = [];
    
    try {
      allArticles.addAll(await _rssService.getNewsByCategory('general'));
    } catch (e) {
      print('RSS Error: $e');
    }
    
    try {
      allArticles.addAll(await _redditService.getNews());
    } catch (e) {
      print('Reddit Error: $e');
    }
    
    try {
      allArticles.addAll(await _wikiService.getCurrentEvents());
    } catch (e) {
      print('Wikipedia Error: $e');
    }

    // Sort by date
    allArticles.sort((a, b) => 
      (b.publishedAt ?? DateTime.now())
        .compareTo(a.publishedAt ?? DateTime.now())
    );
    
    return allArticles;
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