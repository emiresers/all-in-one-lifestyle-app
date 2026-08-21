import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/comment.dart';

class CommentService {
  final String _baseUrl = 'https://dummyjson.com';

  // TÜM YORUMLARI GETİR
  Future<List<Comment>> getComments() async {
    final response = await http.get(Uri.parse('$_baseUrl/comments'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List comments = data['comments'] ?? [];

      return comments.map((json) => Comment.fromJson(json)).toList();
    }

    throw Exception('Yorumlar yüklenemedi.');
  }

  // BİR POSTA AİT YORUMLARI GETİR
  Future<List<Comment>> getCommentsByPost(int postId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/comments/post/$postId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List comments = data['comments'] ?? [];

      return comments.map((json) => Comment.fromJson(json)).toList();
    }

    throw Exception('Post yorumları yüklenemedi.');
  }

  // YORUM EKLE
  Future<Comment> addComment({
    required String body,
    required int postId,
    required int userId,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/comments/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'body': body, 'postId': postId, 'userId': userId}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);

      return Comment.fromJson(data);
    }

    throw Exception('Yorum eklenemedi.');
  }

  // YORUM GÜNCELLE
  Future<Comment> updateComment({
    required int commentId,
    required String body,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/comments/$commentId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'body': body}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return Comment.fromJson(data);
    }

    throw Exception('Yorum güncellenemedi.');
  }

  // YORUM SİL
  Future<Map<String, dynamic>> deleteComment(int commentId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/comments/$commentId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Yorum silinemedi.');
  }
}
