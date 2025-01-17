import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NewsService {
  final String apiKey;
  final NewsAPI newsAPI;

  NewsService(this.apiKey) : newsAPI = NewsAPI(apiKey: apiKey);

  Future<List<Article>> getTopHeadlines({
    required String country,
    required String category,
    int pageSize = 20,
  }) async {
    return await newsAPI.getTopHeadlines(
      country: country,
      category: category,
      pageSize: pageSize,
    );
  }

  Future<List<Article>> getEverything({
    String? query,
    int pageSize = 50,
  }) async {
    return await newsAPI.getEverything(
      query: query,
      pageSize: pageSize,
    );
  }

  Future<List<Article>> getSavedArticles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedUrls = prefs.getStringList('savedArticles') ?? [];
    List<Article> articles = [];

    for (String url in savedUrls) {
      String? articleJson = prefs.getString(url);
      if (articleJson != null) {
        Map<String, dynamic> articleMap = json.decode(articleJson);
        articles.add(Article.fromJson(articleMap));
      }
    }

    return articles;
  }

  Future<void> saveArticle(Article article) async {
    print("here");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("here");

    List<String> savedUrls = prefs.getStringList('savedArticles') ?? [];

    if (!savedUrls.contains(article.url)) {
      savedUrls.add(article.url!);
      await prefs.setStringList('savedArticles', savedUrls);

      Map<String, dynamic> articleMap = {
        'source':{
         "description": article.source.description,
         "id": article.source.id,
          "category":article.source.category,
          "country":article.source.country,
         "language": article.source.language,
          "name":article.source.name,
          "url":article.source.url
        },
        'author': article.author,
        'title': article.title,
        'description': article.description,
        'url': article.url,
        'urlToImage': article.urlToImage,
        'publishedAt': article.publishedAt,
        'content':article.content,
      };
      print(articleMap);
      String articleJson = json.encode(articleMap);
      await prefs.setString(article.url!, articleJson);
    }
  }

  Future<void> removeArticle(Article article) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedUrls = prefs.getStringList('savedArticles') ?? [];

    savedUrls.remove(article.url);
    await prefs.setStringList('savedArticles', savedUrls);
    await prefs.remove(article.url!);
  }
}