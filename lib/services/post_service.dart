import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/post.dart';

class PostService {
  static const String _baseUrl = 'https://dummyjson.com';

  // TÜM POSTLARI GETİR

  Future<List<Post>> getPosts() async {
    final response = await http.get(Uri.parse('$_baseUrl/posts'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      final List<dynamic> postsJson = data['posts'] ?? [];

      return postsJson
          .map((json) => Post.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Postlar yüklenemedi.');
  }

  // TEK POST GETİR

  Future<Post> getPost(int postId) async {
    final response = await http.get(Uri.parse('$_baseUrl/posts/$postId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      return Post.fromJson(data);
    }

    throw Exception('Post detayı yüklenemedi.');
  }

  // POST ARA

  Future<List<Post>> searchPosts(String query) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/posts/search?q=${Uri.encodeQueryComponent(query.trim())}',
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      final List<dynamic> postsJson = data['posts'] ?? [];

      return postsJson
          .map((json) => Post.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Post araması yapılamadı.');
  }

  Future<Map<String, dynamic>> addPost({
    required String title,
    required String body,
    required int userId,
    List<String> tags = const [],
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/posts/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'body': body,
        'userId': userId,
        'tags': tags,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Post eklenemedi.');
  }

  Future<Map<String, dynamic>> updatePost({
    required int postId,
    required String title,
    required String body,
    required List<String> tags,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/posts/$postId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'body': body, 'tags': tags}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Post güncellenemedi.');
  }

  Future<Map<String, dynamic>> deletePost(int postId) async {
    final response = await http.delete(Uri.parse('$_baseUrl/posts/$postId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Post silinemedi.');
  }
}
