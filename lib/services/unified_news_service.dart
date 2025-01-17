import '../models/article.dart';
import '../news_service.dart';
import 'mediastack_service.dart';
import 'gnews_service.dart';
import 'guardian_service.dart';

class UnifiedNewsService {
  final NewsService primaryService;
  final MediastackService backupService1;
  final GNewsService backupService2;
  final GuardianService backupService3;

  UnifiedNewsService({
    required this.primaryService,
    required this.backupService1,
    required this.backupService2,
    required this.backupService3,
  });

  Future<List<Article>> getNews({
    required String category,
    required String country,
    int page = 1,
  }) async {
    try {
      return await primaryService.getTopHeadlines(
        category: category,
        country: country,
        page: page,
      );
    } catch (e) {
      try {
        return await backupService1.getNews(
          category: category,
          country: country,
          offset: (page - 1) * 20,
        );
      } catch (e) {
        try {
          return await backupService2.getTopNews(
            category: category,
            country: country,
            page: page,
          );
        } catch (e) {
          return await backupService3.getArticles(
            section: category,
            page: page,
          );
        }
      }
    }
  }

  Future<List<Article>> getSavedArticles() async {
    return await primaryService.getSavedArticles();
  }

  Future<void> saveArticle(Article article) async {
    await primaryService.saveArticle(article);
  }

  Future<void> removeArticle(Article article) async {
    await primaryService.removeArticle(article);
  }
} 