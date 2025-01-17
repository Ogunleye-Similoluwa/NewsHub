import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/model/source.dart';


class RedditService {
  static const String baseUrl = 'https://www.reddit.com/r';
  static const List<String> subreddits = [
    'news',
    'worldnews',
    'technology',
    'science',
  ];

  Future<List<Article>> getNews() async {
    List<Article> articles = [];
    for (String subreddit in subreddits) {
      final response = await http.get(
        Uri.parse('$baseUrl/$subreddit/hot.json')
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final posts = data['data']['children'] as List;
        
        articles.addAll(posts.map((post) {
          final postData = post['data'];
          final source = Source(
            'reddit',
            'Reddit r/$subreddit',
            'Reddit Content',
            'https://reddit.com',
            'news',
            'en',
            'us'
          );
          final thumbnailUrl = postData['thumbnail']?.toString();
          final hasValidImage = thumbnailUrl != null && thumbnailUrl.contains('http');

          return Article(
            source,
            postData['author'],
            postData['title'],
            postData['selftext'],
            postData['url'],
            hasValidImage ? thumbnailUrl : null,
            DateTime.fromMillisecondsSinceEpoch(
              (postData['created_utc'] as num).toInt() * 1000
            ).toIso8601String(),
            postData['selftext']
          );
        }).toList());
      }
    }
    return articles;
  }

  Future<List<Article>> getNewsByCategory(List<String> subreddits) async {
    List<Article> articles = [];
    for (String subreddit in subreddits) {
      final response = await http.get(
        Uri.parse('$baseUrl/$subreddit/hot.json')
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final posts = data['data']['children'] as List;
        
        articles.addAll(posts.map((post) {
          final postData = post['data'];
          final source = Source(
            'reddit',
            'Reddit r/$subreddit',
            'Reddit Content',
            'https://reddit.com',
            'news',
            'en',
            'us'
          );
          final thumbnailUrl = postData['thumbnail']?.toString();
          final hasValidImage = thumbnailUrl != null && thumbnailUrl.contains('http');

          return Article(
            source,
            postData['author'],
            postData['title'],
            postData['selftext'],
            postData['url'],
            hasValidImage ? thumbnailUrl : null,
            DateTime.fromMillisecondsSinceEpoch(
              (postData['created_utc'] as num).toInt() * 1000
            ).toIso8601String(),
            postData['selftext']
          );
        }).toList());
      }
    }
    return articles;
  }
} 