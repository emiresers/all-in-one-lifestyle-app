import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/todo.dart';

class TodoService {
  static const String _baseUrl = 'https://dummyjson.com';

  Future<List<Todo>> getTodos() async {
    final response = await http.get(Uri.parse('$_baseUrl/todos'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      final List<dynamic> todosJson = data['todos'] ?? [];

      return todosJson
          .map((json) => Todo.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Todo listesi yüklenemedi.');
  }

  Future<List<Todo>> getUserTodos(int userId) async {
    final response = await http.get(Uri.parse('$_baseUrl/todos/user/$userId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      final List<dynamic> todosJson = data['todos'] ?? [];

      return todosJson
          .map((json) => Todo.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Kullanıcı todo listesi yüklenemedi.');
  }

  Future<Todo> addTodo({
    required String todo,
    required bool completed,
    required int userId,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/todos/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'todo': todo,
        'completed': completed,
        'userId': userId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Todo.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }

    throw Exception('Todo eklenemedi.');
  }

  Future<Todo> updateTodo({
    required int todoId,
    required String todo,
    required bool completed,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/todos/$todoId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'todo': todo, 'completed': completed}),
    );

    if (response.statusCode == 200) {
      return Todo.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }

    throw Exception('Todo güncellenemedi.');
  }

  Future<Map<String, dynamic>> deleteTodo(int todoId) async {
    final response = await http.delete(Uri.parse('$_baseUrl/todos/$todoId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Todo silinemedi.');
  }
}
