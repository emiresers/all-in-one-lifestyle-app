class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final double rating;
  final String category;
  final String thumbnail;

  /// Listede yıldızın yanında gösterilen yorum sayısı.
  ///
  /// DummyJSON ürün yanıtında `reviews` dizisi geliyor; alan yoksa 0 kalır.
  final int reviewCount;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rating,
    required this.category,
    required this.thumbnail,
    this.reviewCount = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      category: json['category'],
      thumbnail: json['thumbnail'],
      reviewCount: json['reviews'] is List
          ? (json['reviews'] as List).length
          : 0,
    );
  }
}
