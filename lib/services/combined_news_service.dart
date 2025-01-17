import 'dart:async';
import 'dart:math';
import 'package:news_reader/models/article.dart';
import 'package:news_reader/models/news_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'rss_service.dart';
import 'reddit_service.dart';

class CombinedNewsService {
  final NewsAPI _newsAPI;
  final RSSService _rssService;
  final RedditService _redditService;
  final SharedPreferences _prefs;
  
  static const Map<String, List<String>> categoryMappings = {
    'general': ['news', 'worldnews'],
    'technology': ['technology', 'programming', 'coding'],
    'science': ['science', 'space', 'environment'],
    'business': ['business', 'finance', 'economics'],
    'entertainment': ['entertainment', 'movies', 'music'],
    'sports': ['sports', 'football', 'basketball'],
    'health': ['health', 'medicine', 'covid19'],
  };

  CombinedNewsService._(this._newsAPI, this._rssService, this._redditService, this._prefs);

  static Future<CombinedNewsService> create(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    return CombinedNewsService._(
      NewsAPI(apiKey: apiKey),
      RSSService(),
      RedditService(),
      prefs,
    );
  }

  Future<List<Article>> getNews({
    required String category,
    String? country,
    int page = 1,
  }) async {
    List<Article> allArticles = [];
    List<Future<List<Article>>> futures = [];

    // Add NewsAPI request
    futures.add(_newsAPI.getTopHeadlines(
      category: category,
      country: country ?? 'us',
      page: page,
    ).catchError((e) {
      print('NewsAPI Error: $e');
      return <Article>[];
    }));

    // Add RSS feeds for the category
    futures.add(_rssService.getNewsByCategory(category).catchError((e) {
      print('RSS Error: $e');
      return <Article>[];
    }));

    // Add Reddit posts for the category
    if (categoryMappings.containsKey(category)) {
      futures.add(_redditService.getNewsByCategory(
        categoryMappings[category]!
      ).catchError((e) {
        print('Reddit Error: $e');
        return <Article>[];
      }));
    }

    // Wait for all requests to complete
    final results = await Future.wait(futures);
    
    // Combine and sort results
    for (var articles in results) {
      allArticles.addAll(articles);
    }

    // Sort by date
    allArticles.sort((a, b) => 
      (b.publishedAt ?? DateTime.now())
        .compareTo(a.publishedAt ?? DateTime.now())
    );

    // Remove duplicates based on title similarity
    final uniqueArticles = <Article>[];
    for (var article in allArticles) {
      if (!uniqueArticles.any((a) => _isSimilarTitle(a.title!, article.title!))) {
        uniqueArticles.add(article);
      }
    }

    return uniqueArticles;
  }

  bool _isSimilarTitle(String title1, String title2) {
    final t1 = title1.toLowerCase();
    final t2 = title2.toLowerCase();
    return t1.contains(t2) || t2.contains(t1) || 
           _calculateSimilarity(t1, t2) > 0.8;
  }

  double _calculateSimilarity(String s1, String s2) {
    // Simple Levenshtein distance implementation
    if (s1.isEmpty) return s2.isEmpty ? 1.0 : 0.0;
    if (s2.isEmpty) return 0.0;

    List<int> v0 = List<int>.filled(s2.length + 1, 0);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i < v0.length; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < s2.length; j++) {
        int cost = s1[i] == s2[j] ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost].reduce(min);
      }
      List<int> tmp = v0;
      v0 = v1;
      v1 = tmp;
    }

    return 1.0 - v0[s2.length] / max(s1.length, s2.length);
  }

  // Storage methods
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