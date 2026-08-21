import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/recipe.dart';

class RecipeService {
  static const String _baseUrl = 'https://dummyjson.com';

  // Tüm tarifleri getirir
  Future<List<Recipe>> getRecipes() async {
    final response = await http.get(Uri.parse('$_baseUrl/recipes'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      final List<dynamic> recipesJson = data['recipes'];

      return recipesJson.map((json) => Recipe.fromJson(json)).toList();
    }

    throw Exception('Tarifler yüklenemedi.');
  }

  Future<Recipe> getRecipe(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/recipes/$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      return Recipe.fromJson(data);
    }

    throw Exception('Tarif yüklenemedi.');
  }
}
