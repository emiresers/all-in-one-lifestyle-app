class Post {
  final int id;
  final String title;
  final String body;
  final List<String> tags;
  final int views;
  final int userId;
  final int likes;
  final int dislikes;

  const Post({
    required this.id,
    required this.title,
    required this.body,
    required this.tags,
    required this.views,
    required this.userId,
    required this.likes,
    required this.dislikes,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> reactions =
        json['reactions'] is Map<String, dynamic>
        ? json['reactions'] as Map<String, dynamic>
        : {};

    return Post(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      views: json['views'] ?? 0,
      userId: json['userId'] ?? 0,
      likes: reactions['likes'] ?? 0,
      dislikes: reactions['dislikes'] ?? 0,
    );
  }
}
