import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_reader/services/combined_news_service.dart';
import 'services/storage_service.dart';

enum LoadingState { initial, loading, loaded, error }
enum ErrorType { network, api, unknown }

class NewsProvider with ChangeNotifier {
  final CombinedNewsService _newsService;
  final StorageService _storageService;
  
  List<Article> _articles = [];
  List<Article> _savedArticles = [];
  LoadingState _loadingState = LoadingState.initial;
  ErrorType? _errorType;
  String? _errorMessage;
  
  Set<String> _userTags = {};
  String _selectedCategory = "general";
  String _selectedCountry = "us";
  String? _searchQuery;
  int _currentPage = 1;
  List<Article> _trendingArticles = [];

  NewsProvider({
    required CombinedNewsService newsService,
    required StorageService storageService,
  }) : _newsService = newsService,
       _storageService = storageService {
    _loadSavedArticles();
    fetchTrendingNews();
  }

  List<Article> get articles => _articles;
  List<Article> get savedArticles => _savedArticles;
  Set<String> get userTags => _userTags;
  bool get isLoading => _loadingState == LoadingState.loading;
  LoadingState get loadingState => _loadingState;
  ErrorType? get errorType => _errorType;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get selectedCountry => _selectedCountry;
  String? get searchQuery => _searchQuery;
  List<Article> get trendingArticles => _trendingArticles;

  Future<void> fetchNews({bool refresh = false}) async {
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      await _searchNews(refresh: refresh);
      return;
    }

    if (refresh) _currentPage = 1;

    if (_currentPage == 1) {
      _loadingState = LoadingState.loading;
      notifyListeners();
    }

    try {
      final hasInternet = await InternetConnectionChecker().hasConnection;
      
      if (!hasInternet) {
        if (_currentPage == 1) {
          _articles = _storageService.getCachedArticles();
          _loadingState = LoadingState.loaded;
          _errorType = ErrorType.network;
          _errorMessage = 'No internet connection. Showing cached content.';
          notifyListeners();
        }
        return;
      }
      final newArticles = await _newsService.getNews(
        category: _selectedCategory,
        country: _selectedCountry,
        page: _currentPage,
      );

      if (_currentPage == 1) {
        _articles = newArticles;
        await _storageService.cacheArticles(newArticles);
      } else {
        _articles.addAll(newArticles);
      }

      _currentPage++;
      _loadingState = LoadingState.loaded;
      _errorType = null;
      _errorMessage = null;

    } catch (e) {
      _errorMessage = 'Failed to load news. Trying alternative sources...';
      _errorMessage = 'Failed to load news. Please try again.';
      _loadingState = LoadingState.error;
      print("Error fetching news: $e");
    }
    notifyListeners();
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
    if (query == null || query.isEmpty) {
      clearSearch();
      return;
    }
    
    _searchQuery = query;
    _currentPage = 1;
    _searchNews(refresh: true);
  }

  Future<void> _searchNews({bool refresh = false}) async {
    if (refresh) _currentPage = 1;

    if (_currentPage == 1) {
      _loadingState = LoadingState.loading;
      notifyListeners();
    }

    try {
      final hasInternet = await InternetConnectionChecker().hasConnection;
      
      if (!hasInternet) {
        _errorType = ErrorType.network;
        _errorMessage = 'No internet connection.';
        _loadingState = LoadingState.error;
        notifyListeners();
        return;
      }

      final searchResults = await _newsService.searchNews(
        _searchQuery!,
        page: _currentPage,
      );

      if (_currentPage == 1) {
        _articles = searchResults;
      } else {
        _articles.addAll(searchResults);
      }

      _currentPage++;
      _loadingState = LoadingState.loaded;
      _errorType = null;
      _errorMessage = null;

    } catch (e) {
      _errorMessage = 'Failed to search news. Please try again.';
      _loadingState = LoadingState.error;
      print("Error searching news: $e");
    }
    notifyListeners();
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
    try {
      _loadingState = LoadingState.loading;
      notifyListeners();
      
      _trendingArticles = await _newsService.getTrendingNews();
      _loadingState = LoadingState.loaded;
      
      notifyListeners();
    } catch (e) {
      print("Error fetching trending news: $e");
      _trendingArticles = [];
      _loadingState = LoadingState.error;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchQuery = null;
    _currentPage = 1;
    fetchNews(refresh: true);
  }
}