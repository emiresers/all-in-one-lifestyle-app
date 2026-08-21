import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user.dart';

class UserService {
  static const String _baseUrl = 'https://dummyjson.com';

  // Tüm kullanıcıları getir
  Future<List<User>> getUsers({int limit = 30, int skip = 0}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users?limit=$limit&skip=$skip'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      final List<dynamic> usersJson = data['users'];

      return usersJson.map((json) => User.fromJson(json)).toList();
    }

    throw Exception('Kullanıcılar yüklenemedi.');
  }

  // ID'ye göre tek kullanıcı getir
  Future<User> getUser(int userId) async {
    final response = await http.get(Uri.parse('$_baseUrl/users/$userId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      return User.fromJson(data);
    }

    throw Exception('Kullanıcı yüklenemedi.');
  }

  // Kullanıcı ara
  Future<List<User>> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      return getUsers();
    }

    final response = await http.get(
      Uri.parse(
        '$_baseUrl/users/search?q=${Uri.encodeQueryComponent(query.trim())}',
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      final List<dynamic> usersJson = data['users'];

      return usersJson.map((json) => User.fromJson(json)).toList();
    }

    throw Exception('Kullanıcı araması başarısız oldu.');
  }

  // Kullanıcıları filtrele
  Future<List<User>> filterUsers({
    required String key,
    required String value,
  }) async {
    final uri = Uri.parse('$_baseUrl/users/filter')
        .replace(queryParameters: {'key': key, 'value': value});

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      final List<dynamic> usersJson = data['users'];

      return usersJson.map((json) => User.fromJson(json)).toList();
    }

    throw Exception('Kullanıcılar filtrelenemedi.');
  }

  Future<Map<String, dynamic>> addUser({
    required String firstName,
    required String lastName,
    required int age,
    required String gender,
    required String email,
    required String phone,
    required String username,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'age': age,
        'gender': gender,
        'email': email,
        'phone': phone,
        'username': username,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Kullanıcı eklenemedi.');
  }

  Future<Map<String, dynamic>> updateUser({
    required int userId,
    required String firstName,
    required String lastName,
    required int age,
    required String gender,
    required String email,
    required String phone,
    required String username,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/users/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'age': age,
        'gender': gender,
        'email': email,
        'phone': phone,
        'username': username,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Kullanıcı güncellenemedi.');
  }

  Future<Map<String, dynamic>> deleteUser(int userId) async {
    final response = await http.delete(Uri.parse('$_baseUrl/users/$userId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Kullanıcı silinemedi.');
  }
}
