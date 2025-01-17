# NewsHub

NewsHub is a modern news aggregator app built with Flutter that combines multiple news sources to provide a comprehensive news reading experience.

## Screenshots

<p float="left">
  <img src="screenshots/home_screen.png" width="200" alt="Home Screen"/>
  <img src="screenshots/trending_screen.png" width="200" alt="Trending News"/>
  <img src="screenshots/search_screen.png" width="200" alt="Search"/>
  <img src="screenshots/saved_articles.png" width="200" alt="Saved Articles"/>
</p>



## Features

- **Multiple News Sources**
  - NewsAPI integration for official news
  - Reddit integration for community discussions
  - RSS feeds for direct publisher content
  - Wikipedia current events

- **Smart Search**
  - Search across all sources simultaneously
  - Keyword-based matching
  - Relevancy sorting
  - Support for partial matches

- **Category Navigation**
  - General News
  - Technology
  - Business
  - Entertainment
  - Sports
  - Science
  - Health

- **Trending News**
  - Top headlines from multiple countries
  - Cross-category trending stories
  - Real-time updates

- **Article Management**
  - Save articles for offline reading
  - Bookmark favorite stories
  - Share articles

- **User Experience**
  - Clean, modern UI
  - Pull-to-refresh
  - Infinite scrolling
  - Loading animations
  - Error handling with retry options
  - Offline support

## Architecture

- **Provider Pattern** for state management
- **Service Layer** for API interactions
- **Repository Pattern** for data handling
- **Clean Architecture** principles

## Dependencies

- `news_api_flutter_package`: Official NewsAPI client
- `provider`: State management
- `shared_preferences`: Local storage
- `http`: Network requests
- `pull_to_refresh`: Refresh functionality
- `shimmer`: Loading animations
- `cached_network_image`: Image caching
- `url_launcher`: External link handling


