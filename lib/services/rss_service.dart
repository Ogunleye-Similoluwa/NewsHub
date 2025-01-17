import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../models/article.dart';

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
          String? imageUrl = item.findElements('media:content').firstOrNull?.getAttribute('url') ??
                           item.findElements('enclosure').firstOrNull?.getAttribute('url');
          
          return Article(
            title: item.findElements('title').firstOrNull?.text,
            description: item.findElements('description').firstOrNull?.text?.replaceAll(RegExp(r'<[^>]*>'), ''),
            url: item.findElements('link').firstOrNull?.text,
            urlToImage: imageUrl,
            publishedAt: DateTime.tryParse(
              item.findElements('pubDate').firstOrNull?.text ?? ''
            ),
            author: item.findElements('author').firstOrNull?.text,
            source: Source(name: Uri.parse(feed).host),
          );
        }).toList());
      }
    }
    return articles;
  }
} 