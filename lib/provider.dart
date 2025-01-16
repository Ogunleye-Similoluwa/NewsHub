import 'package:flutter/foundation.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'news_service.dart';

class NewsProvider with ChangeNotifier {
  final NewsService _newsService;
  List<Article> _articles = [];
  List<Article> _savedArticles = [];
  Set<String> _userTags = {};
  bool _isLoading = false;
  String _selectedCategory = "general";
  String _selectedCountry = "us";
  String? _searchQuery;
  int _currentPage = 1;
  List<Article> _trendingArticles = [];

  NewsProvider(String apiKey) : _newsService = NewsService(apiKey) {
    _loadSavedArticles();
  }

  List<Article> get articles => _articles;
  List<Article> get savedArticles => _savedArticles;
  Set<String> get userTags => _userTags;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get selectedCountry => _selectedCountry;
  String? get searchQuery => _searchQuery;
  List<Article> get trendingArticles => _trendingArticles;

  Future<void> fetchNews({bool refresh = false}) async {
    if (refresh) _currentPage = 1;

    if (_currentPage == 1) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final newArticles = await _newsService.getTopHeadlines(
        country: _selectedCountry,
        category: _selectedCategory,
        query: _searchQuery,
        pageSize: 50
      );

      if (_currentPage == 1) {
        _articles = newArticles;
      } else {
        _articles.addAll(newArticles);
      }

      _currentPage++;
    } catch (e) {
      print("Error fetching news: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    _selectedCategory = category.toLowerCase();
    _currentPage = 1;
    fetchNews(refresh: true);
  }

  void setCountry(String country) {
    _selectedCountry = country.toLowerCase();
    _currentPage = 1;
    fetchNews(refresh: true);
  }

  void setSearchQuery(String? query) {
    _searchQuery = query;
    _currentPage = 50;
    fetchNews(refresh: true);
  }

  Future<void> toggleSaveArticle(Article article) async {
    print(article.url);
    if (_savedArticles.any((a) => a.url == article.url)) {
      await _newsService.removeArticle(article);
      _savedArticles.removeWhere((a) => a.url == article.url);
    } else {
      await _newsService.saveArticle(article);
      _savedArticles.add(article);
    }
    notifyListeners();
  }

  Future<void> _loadSavedArticles() async {
    _savedArticles = await _newsService.getSavedArticles();
    notifyListeners();
  }

  bool isArticleSaved(Article article) {
    return _savedArticles.any((a) => a.url == article.url);
  }

  Future<void> fetchTrendingNews() async {
    // Implement trending news fetching logic
    // You might want to sort by popularity or use a different API endpoint
  }
}