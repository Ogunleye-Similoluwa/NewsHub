import 'dart:async';
import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/model/source.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'rss_service.dart';
import 'reddit_service.dart';
import 'wikipedia_service.dart';

class CombinedNewsService {
  final NewsAPI _newsAPI;
  final RSSService _rssService;
  final RedditService _redditService;
  final WikipediaService _wikiService;
  final SharedPreferences _prefs;

  CombinedNewsService._(this._newsAPI, this._rssService, this._redditService, this._wikiService, this._prefs);

  static const Map<String, List<String>> categoryMappings = {
    'general': ['news', 'worldnews'],
    'technology': ['technology', 'programming', 'coding'],
    'science': ['science', 'space', 'environment'],
    'business': ['business', 'finance', 'economics'],
    'entertainment': ['entertainment', 'movies', 'music'],
    'sports': ['sports', 'football', 'basketball'],
    'health': ['health', 'medicine', 'covid19'],
  };

  static Future<CombinedNewsService> create(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    return CombinedNewsService._(
      NewsAPI(apiKey: apiKey),
      RSSService(),
      RedditService(),
      WikipediaService(),
      prefs,
    );
  }

  Future<List<Article>> getNews({
    required String category,
    required String country,
    int page = 1,
  }) async {
    List<Article> allArticles = [];
    List<Future<List<Article>>> futures = [];

    // Get news from NewsAPI
    futures.add(
      _newsAPI.getTopHeadlines(
        category: category,
        country: country,
        page: page,
      ).catchError((e) {
        print('NewsAPI Error: $e');
        return <Article>[];
      })
    );

    // Get news from RSS feeds with category
    futures.add(
      _rssService.getNewsByCategory(category).catchError((e) {
        print('RSS Error: $e');
        return <Article>[];
      })
    );

    // Get news from Reddit with mapped categories
    if (categoryMappings.containsKey(category)) {
      futures.add(
        _redditService.getNewsByCategory(categoryMappings[category]!).catchError((e) {
          print('Reddit Error: $e');
          return <Article>[];
        })
      );
    }

    // Always get Wikipedia current events as backup
    futures.add(
      _wikiService.getCurrentEvents().catchError((e) {
        print('Wikipedia Error: $e');
        return <Article>[];
      })
    );

    // If we're getting general news, add some backup categories
    if (category == 'general') {
      futures.addAll([
        _rssService.getNewsByCategory('technology'),
        _rssService.getNewsByCategory('business'),
        _rssService.getNewsByCategory('entertainment'),
      ].map((future) => future.catchError((e) => <Article>[])));
    }

    final results = await Future.wait(futures);
    
    for (var articles in results) {
      allArticles.addAll(articles);
    }

    // Remove duplicates and sort
    final uniqueArticles = <Article>[];
    final uniqueUrls = <String>{};
    
    for (var article in allArticles) {
      if (article.url != null && !uniqueUrls.contains(article.url)) {
        uniqueUrls.add(article.url!);
        uniqueArticles.add(article);
      }
    }

    uniqueArticles.sort((a, b) {
      final dateA = DateTime.tryParse(a.publishedAt ?? '') ?? DateTime.now();
      final dateB = DateTime.tryParse(b.publishedAt ?? '') ?? DateTime.now();
      return dateB.compareTo(dateA);
    });

    // Limit to 50 articles per page
    final startIndex = (page - 1) * 50;
    final endIndex = startIndex + 50;
    
    if (startIndex >= uniqueArticles.length) {
      return [];
    }
    
    return uniqueArticles.sublist(
      startIndex,
      endIndex > uniqueArticles.length ? uniqueArticles.length : endIndex
    );
  }

  Future<List<Article>> getTrendingNews() async {
    List<Article> allArticles = [];
    List<Future<List<Article>>> futures = [];

    // Get top headlines from multiple countries for better variety
    final countries = ['us', 'gb', 'in'];
    
    for (var country in countries) {
      futures.add(
        _newsAPI.getTopHeadlines(
          category: 'general',
          country: country,
          pageSize: 10,
        ).catchError((e) {
          print('NewsAPI Error for $country: $e');
          return <Article>[];
        })
      );
    }

    // Get top headlines from different categories
    final categories = ['technology', 'business', 'entertainment', 'sports'];
    for (var category in categories) {
      futures.add(
        _newsAPI.getTopHeadlines(
          category: category,
          country: 'us',
          pageSize: 5,
        ).catchError((e) {
          print('NewsAPI Error for $category: $e');
          return <Article>[];
        })
      );
    }

    // Get top Reddit posts
    futures.add(
      _redditService.getNewsByCategory(['news', 'worldnews']).catchError((e) {
        print('Reddit Error: $e');
        return <Article>[];
      })
    );

    final results = await Future.wait(futures);
    
    for (var articles in results) {
      allArticles.addAll(articles);
    }

    // Remove duplicates
    final uniqueArticles = <Article>[];
    final uniqueUrls = <String>{};
    
    for (var article in allArticles) {
      if (article.url != null && !uniqueUrls.contains(article.url)) {
        uniqueUrls.add(article.url!);
        uniqueArticles.add(article);
      }
    }

    // Sort by date
    uniqueArticles.sort((a, b) {
      final dateA = DateTime.tryParse(a.publishedAt ?? '') ?? DateTime.now();
      final dateB = DateTime.tryParse(b.publishedAt ?? '') ?? DateTime.now();
      return dateB.compareTo(dateA);
    });

    // Return top 20 trending articles
    return uniqueArticles.take(20).toList();
  }

  // Storage methods
  Future<List<Article>> getSavedArticles() async {
    List<String> savedUrls = _prefs.getStringList('savedArticles') ?? [];
    List<Article> articles = [];
    
    for (String url in savedUrls) {
      try {
        String? json = _prefs.getString(url);
        if (json != null) {
          final Map<String, dynamic> articleMap = jsonDecode(json);
          articles.add(Article(
            Source(
              articleMap['source']['id'],
              articleMap['source']['name'],
              articleMap['source']['description'],
              articleMap['source']['url'],
              articleMap['source']['category'],
              articleMap['source']['language'],
              articleMap['source']['country'],
            ),
            articleMap['author'],
            articleMap['title'],
            articleMap['description'],
            articleMap['url'],
            articleMap['urlToImage'],
            articleMap['publishedAt'],
            articleMap['content'],
          ));
        }
      } catch (e) {
        print('Error decoding saved article: $e');
      }
    }
    return articles;
  }

  Future<void> saveArticle(Article article) async {
    List<String> savedUrls = _prefs.getStringList('savedArticles') ?? [];
    if (!savedUrls.contains(article.url)) {
      savedUrls.add(article.url!);
      await _prefs.setStringList('savedArticles', savedUrls);

      // Convert Article to JSON-encodable map
      final articleMap = {
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
      };

      await _prefs.setString(article.url!, jsonEncode(articleMap));
    }
  }

  Future<void> removeArticle(Article article) async {
    List<String> savedUrls = _prefs.getStringList('savedArticles') ?? [];
    savedUrls.remove(article.url);
    await _prefs.setStringList('savedArticles', savedUrls);
    await _prefs.remove(article.url!);
  }

  Future<List<Article>> searchNews(String query, {int page = 1}) async {
    List<Article> allArticles = [];
    List<Future<List<Article>>> futures = [];

    // Split search query into keywords
    final keywords = query.toLowerCase().split(' ');

    // Search NewsAPI everything endpoint with original query
    futures.add(
      _newsAPI.getEverything(
        query: query,
        page: page,
        pageSize: 50,
        sortBy: 'relevancy',
      ).catchError((e) {
        print('NewsAPI Search Error: $e');
        return <Article>[];
      })
    );

    // Search across all RSS categories
    for (var category in categoryMappings.keys) {
      futures.add(
        _rssService.getNewsByCategory(category).then((articles) {
          return articles.where((article) {
            final title = article.title?.toLowerCase() ?? '';
            final description = article.description?.toLowerCase() ?? '';
            final content = article.content?.toLowerCase() ?? '';
            
            // Check if any keyword matches
            return keywords.any((keyword) =>
              title.contains(keyword) ||
              description.contains(keyword) ||
              content.contains(keyword)
            );
          }).toList();
        }).catchError((e) {
          print('RSS Search Error: $e');
          return <Article>[];
        })
      );
    }

    // Search Reddit
    futures.add(
      _redditService.getNews().then((articles) {
        return articles.where((article) {
          final title = article.title?.toLowerCase() ?? '';
          final description = article.description?.toLowerCase() ?? '';
          final content = article.content?.toLowerCase() ?? '';
          
          return keywords.any((keyword) =>
            title.contains(keyword) ||
            description.contains(keyword) ||
            content.contains(keyword)
          );
        }).toList();
      }).catchError((e) {
        print('Reddit Search Error: $e');
        return <Article>[];
      })
    );

    final results = await Future.wait(futures);
    
    for (var articles in results) {
      allArticles.addAll(articles);
    }

    // Remove duplicates and sort
    final uniqueArticles = <Article>[];
    final uniqueUrls = <String>{};
    
    for (var article in allArticles) {
      if (article.url != null && !uniqueUrls.contains(article.url)) {
        uniqueUrls.add(article.url!);
        uniqueArticles.add(article);
      }
    }

    uniqueArticles.sort((a, b) {
      final dateA = DateTime.tryParse(a.publishedAt ?? '') ?? DateTime.now();
      final dateB = DateTime.tryParse(b.publishedAt ?? '') ?? DateTime.now();
      return dateB.compareTo(dateA);
    });

    // Paginate results
    final startIndex = (page - 1) * 50;
    final endIndex = startIndex + 50;
    
    if (startIndex >= uniqueArticles.length) {
      return [];
    }
    
    return uniqueArticles.sublist(
      startIndex,
      endIndex > uniqueArticles.length ? uniqueArticles.length : endIndex
    );
  }
} 