import 'package:http/http.dart' as http;
import 'package:news_api_flutter_package/model/article.dart';
import 'package:xml/xml.dart';

import 'package:news_api_flutter_package/model/source.dart';

class RSSService {
  static const Map<String, List<String>> categoryFeeds = {
    'general': [
      'https://feeds.bbci.co.uk/news/world/rss.xml',
      'https://rss.nytimes.com/services/xml/rss/nyt/World.xml',
    ],
    'technology': [
      'https://feeds.feedburner.com/TechCrunch',
      'https://www.wired.com/feed/rss',
      'https://www.theverge.com/rss/index.xml',
    ],
    'science': [
      'https://www.sciencedaily.com/rss/all.xml',
      'https://www.nature.com/nature.rss',
    ],
    'business': [
      'https://feeds.bloomberg.com/markets/news.rss',
      'https://www.forbes.com/business/feed/',
    ],
    'entertainment': [
      'https://variety.com/feed/',
      'https://deadline.com/feed/',
    ],
    'sports': [
      'https://www.espn.com/espn/rss/news',
      'https://www.sports.yahoo.com/rss/',
    ],
    'health': [
      'https://www.who.int/rss-feeds/news-english.xml',
      'https://www.health.harvard.edu/blog/feed',
    ],
  };

  Future<List<Article>> getNewsByCategory(String category) async {
    final feeds = categoryFeeds[category] ?? categoryFeeds['general']!;
    return getNewsFromFeeds(feeds);
  }

  Future<List<Article>> getNewsFromFeeds(List<String> feeds) async {
    List<Article> articles = [];
    for (String feed in feeds) {
      final response = await http.get(Uri.parse(feed));
      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final items = document.findAllElements('item');
        
        articles.addAll(items.map((item) {
          final source = Source(
            Uri.parse(feed).host,
            Uri.parse(feed).host,
            'RSS Feed',
            feed,
            'general',
            'en',
            'us'
          );
          final thumbnailUrl = item.findElements('media:content').firstOrNull?.getAttribute('url') ??
                                item.findElements('enclosure').firstOrNull?.getAttribute('url');
          return Article(
            source,
            item.findElements('author').firstOrNull?.text,
            item.findElements('title').firstOrNull?.text,
            item.findElements('description').firstOrNull?.text?.replaceAll(RegExp(r'<[^>]*>'), ''),
            item.findElements('link').firstOrNull?.text,
            thumbnailUrl != null && thumbnailUrl.isNotEmpty ? thumbnailUrl : null,
            DateTime.tryParse(item.findElements('pubDate').firstOrNull?.text ?? '')?.toIso8601String(),
            item.findElements('content:encoded').firstOrNull?.text
          );
        }).toList());
      }
    }
    return articles;
  }
} 
