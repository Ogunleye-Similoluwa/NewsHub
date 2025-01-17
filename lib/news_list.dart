import 'package:flutter/cupertino.dart';
import 'package:news_api_flutter_package/model/article.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'news_item.dart';

class NewsList extends StatelessWidget {
  final List<Article> articles;
  final RefreshController refreshController;
  final Function onRefresh;
  final Function? onLoading;

  const NewsList({
    Key? key,
    required this.articles,
    required this.refreshController,
    required this.onRefresh,
    this.onLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: refreshController,
      onRefresh: () => onRefresh(),
      onLoading: onLoading != null ? () => onLoading!() : null,
      enablePullDown: true,
      enablePullUp: onLoading != null,
      child: articles.isEmpty
          ? Center(child: Text("No articles available"))
          : ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {
          return NewsItem(article: articles[index]);
        },
      ),
    );
  }
}