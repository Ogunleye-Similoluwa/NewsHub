import 'package:flutter/material.dart';
import 'package:news_reader/provider.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:news_api_flutter_package/model/article.dart';

import 'category_list.dart';
import 'news_list.dart';

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final RefreshController _refreshController = RefreshController();
  final RefreshController _refreshController2 = RefreshController();

  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsProvider>().fetchNews();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _refreshController.dispose();
    _refreshController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(),
          _buildCategoryBar(),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildNewsTab(),
            _buildSavedNewsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final theme = Theme.of(context);
    return SliverAppBar(
      expandedHeight: isSearching ? 0 : 120,
      pinned: true,
      flexibleSpace: isSearching
          ? null
          : FlexibleSpaceBar(
        title: Text('News App', style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white)),
        background: Container(color: theme.primaryColor),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(isSearching ? 60 : 48),
        child: isSearching
            ? Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search news...',
              filled: true,
              fillColor: Colors.white,
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  context.read<NewsProvider>().setSearchQuery(null);
                },
              ),
            ),
            onSubmitted: (value) {
              context.read<NewsProvider>().setSearchQuery(value);
            },
          ),
        )
            : TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Headlines'),
            Tab(text: 'Saved'),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              isSearching = !isSearching;
              if (!isSearching) {
                _searchController.clear();
                context.read<NewsProvider>().setSearchQuery(null);
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildCategoryBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverCategoryBarDelegate(
        child: CategoryList(),
      ),
    );
  }



  Widget _buildNewsTab() {
    return Consumer<NewsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.articles.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }
        return NewsList(
          articles: provider.articles,
          refreshController: _refreshController,
          onRefresh: () async {
            await provider.fetchNews(refresh: true);
            _refreshController.refreshCompleted();
          },
          onLoading: () async {
            await provider.fetchNews();
            _refreshController.requestRefresh();
          },
        );
      },
    );
  }

  Widget _buildSavedNewsTab() {
    return Consumer<NewsProvider>(
      builder: (context, provider, child) {
        return NewsList(
          articles: provider.savedArticles,
          refreshController: _refreshController2,
          onRefresh: () async {
            _refreshController2.requestRefresh();
            // _refreshController.refreshCompleted();
          },
        );
      },
    );
  }
}

class _SliverCategoryBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverCategoryBarDelegate({required this.child});

  @override
  double get minExtent => 50.0;
  @override
  double get maxExtent => 50.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }

  @override
  bool shouldRebuild(_SliverCategoryBarDelegate oldDelegate) {
    return false;
  }
}