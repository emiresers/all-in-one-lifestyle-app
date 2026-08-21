class Quote {
  final int id;
  final String quote;
  final String author;

  const Quote({required this.id, required this.quote, required this.author});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] ?? 0,
      quote: json['quote'] ?? '',
      author: json['author'] ?? '',
    );
  }
}
