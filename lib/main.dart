import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'services/storage_service.dart';
import 'services/free_news_service.dart';
import 'services/combined_news_service.dart';

import 'provider.dart';
import 'app_theme.dart';
import 'news_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  final apiKey = dotenv.env['NEWS_API_KEY'] ?? '';
  
  final storageService = StorageService();
  await storageService.init();

  final combinedNewsService = await CombinedNewsService.create(apiKey);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => NewsProvider(
            newsService: combinedNewsService,
            storageService: storageService,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: NewsHubPage(),
    );
  }
}
