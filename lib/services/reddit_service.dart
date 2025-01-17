import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/article.dart';

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
          return Article(
            title: postData['title'],
            url: postData['url'],
            description: postData['selftext'],
            urlToImage: postData['thumbnail']!.toString().contains('http') 
                ? postData['thumbnail'] 
                : null,
            author: postData['author'],
            publishedAt: DateTime.fromMillisecondsSinceEpoch(
              (postData['created_utc'] as num).toInt() * 1000
            ),
            source: Source(name: 'Reddit r/$subreddit'),
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
          return Article(
            title: postData['title'],
            url: postData['url'],
            description: postData['selftext'],
            urlToImage: postData['thumbnail']!.toString().contains('http') 
                ? postData['thumbnail'] 
                : null,
            author: postData['author'],
            publishedAt: DateTime.fromMillisecondsSinceEpoch(
              (postData['created_utc'] as num).toInt() * 1000
            ),
            source: Source(name: 'Reddit r/$subreddit'),
          );
        }).toList());
      }
    }
    return articles;
  }
} 