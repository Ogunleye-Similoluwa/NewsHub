import 'package:flutter/material.dart';
import 'package:news_reader/provider.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:shimmer/shimmer.dart';

import 'category_list.dart';
import 'news_list.dart';

class NewsHubPage extends StatefulWidget {
  @override
  _NewsHubPageState createState() => _NewsHubPageState();
}

class _NewsHubPageState extends State<NewsHubPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final RefreshController _refreshController = RefreshController();
  final RefreshController _refreshController2 = RefreshController();

  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool _showFloatingButton = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsProvider>().fetchNews();
    });
  }

  void _scrollListener() {
    if (_scrollController.offset >= 100) {
      if (!_showFloatingButton) {
        setState(() => _showFloatingButton = true);
      }
    } else {
      if (_showFloatingButton) {
        setState(() => _showFloatingButton = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _refreshController.dispose();
    _refreshController2.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(),
          _buildCategoryBar(),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildNewsTab(),
            _buildTrendingTab(),
            _buildSavedNewsTab(),
          ],
        ),
      ),
      floatingActionButton: _showFloatingButton
          ? FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              child: Icon(Icons.arrow_upward),
              tooltip: 'Scroll to top',
            )
          : null,
    );
  }

  Widget _buildSliverAppBar() {
    final theme = Theme.of(context);
    return SliverAppBar(
      expandedHeight: isSearching ? 0 : 150,
      pinned: true,
      elevation: 0,
      backgroundColor: theme.primaryColor,
      flexibleSpace: isSearching
          ? null
          : FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: EdgeInsets.only(left: 16, bottom: 60),
              title: AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'NewsHub',
                    textStyle: GoogleFonts.montserrat(
                      textStyle: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    speed: Duration(milliseconds: 200),
                  ),
                ],
                totalRepeatCount: 1,
                displayFullTextOnTap: true,
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.newspaper,
                    size: 50,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
              ),
            ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(isSearching ? 60 : 48),
        child: isSearching
            ? _buildSearchBar()
            : _buildTabBar(theme),
      ),
      actions: _buildAppBarActions(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search news...',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(Icons.search),
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
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return TabBar(
      controller: _tabController,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(width: 3, color: Colors.white),
        insets: EdgeInsets.symmetric(horizontal: 30),
      ),
      tabs: [
        Tab(
          icon: Icon(Icons.public),
          text: 'Headlines',
        ),
        Tab(
          icon: Icon(Icons.trending_up),
          text: 'Trending',
        ),
        Tab(
          icon: Icon(Icons.bookmark),
          text: 'Saved',
        ),
      ],
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
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
      PopupMenuButton<String>(
        icon: Icon(Icons.more_vert),
        onSelected: (value) {
          // Handle menu item selection
          switch (value) {
            case 'settings':
              // Navigate to settings
              break;
            case 'about':
              _showAboutDialog();
              break;
          }
        },
        itemBuilder: (BuildContext context) => [
          PopupMenuItem(
            value: 'settings',
            child: ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
            ),
          ),
          PopupMenuItem(
            value: 'about',
            child: ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
            ),
          ),
        ],
      ),
    ];
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About NewsHub'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NewsHub brings you the latest news from around the world.'),
            SizedBox(height: 8),
            Text('Version: 1.0.0'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
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
        if (provider.loadingState == LoadingState.loading && 
            provider.articles.isEmpty) {
          return _buildLoadingShimmer();
        }
        
        if (provider.loadingState == LoadingState.error) {
          return _buildErrorState(
            provider.errorType!, 
            provider.errorMessage!
          );
        }

        if (provider.articles.isEmpty) {
          return Center(
            child: Text('No articles found'),
          );
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
            _refreshController.loadComplete();
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

  Widget _buildTrendingTab() {
    return Consumer<NewsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.trendingArticles.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }
        return NewsList(
          articles: provider.trendingArticles,
          refreshController: RefreshController(),
          onRefresh: () async {
            await provider.fetchTrendingNews();
            _refreshController.refreshCompleted();
          },
        );
      },
    );
  }

  Widget _buildErrorState(ErrorType type, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            type == ErrorType.network 
                ? Icons.wifi_off 
                : Icons.error_outline,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<NewsProvider>().fetchNews(refresh: true),
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          margin: EdgeInsets.all(8),
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
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