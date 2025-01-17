class Article {
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final DateTime? publishedAt;
  final String? content;
  final String? author;
  final Source? source;

  Article({
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.author,
    this.source,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      source: Source(name: json['source']['name']),
      author: json['author'],
      title: json['title'],
      description: json['description'],
      url: json['url'],
      urlToImage: json['urlToImage'],
      publishedAt: json['publishedAt'] != null 
          ? DateTime.parse(json['publishedAt']) 
          : null,
      content: json['content'],
    );
  }

  factory Article.fromMediastack(Map<String, dynamic> json) {
    return Article(
      title: json['title'],
      description: json['description'],
      url: json['url'],
      urlToImage: json['image'],
      publishedAt: DateTime.tryParse(json['published_at']),
      author: json['author'],
      source: Source(name: json['source']),
    );
  }

  factory Article.fromGNews(Map<String, dynamic> json) {
    return Article(
      title: json['title'],
      description: json['description'],
      url: json['url'],
      urlToImage: json['image'],
      publishedAt: DateTime.tryParse(json['publishedAt']),
      content: json['content'],
      source: Source(name: json['source']['name']),
    );
  }

  factory Article.fromGuardian(Map<String, dynamic> json) {
    final fields = json['fields'] ?? {};
    return Article(
      title: json['webTitle'],
      description: fields['trailText'],
      url: json['webUrl'],
      urlToImage: fields['thumbnail'],
      publishedAt: DateTime.tryParse(json['webPublicationDate']),
      content: fields['bodyText'],
      source: Source(name: 'The Guardian'),
    );
  }
}

class Source {
  final String? name;
  final String? description;
  final String? id;
  final String? category;
  final String? language;
  final String? country;
  final String? url;

  Source({
    this.name,
    this.description,
    this.id,
    this.category,
    this.language,
    this.country,
    this.url,
  });
} 