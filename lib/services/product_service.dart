import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductService {
  static const String _baseUrl = 'https://dummyjson.com';

  Future<List<Product>> getProducts({int limit = 10, int skip = 0}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/products?limit=$limit&skip=$skip'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      final List<dynamic> productsJson = data['products'];

      return productsJson.map((json) => Product.fromJson(json)).toList();
    }

    throw Exception('Ürünler yüklenemedi.');
  }

  Future<List<Product>> searchProducts(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/products/search?q=$query'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      final List<dynamic> productsJson = data['products'];

      return productsJson.map((json) => Product.fromJson(json)).toList();
    }

    throw Exception('Arama sonucu yüklenemedi.');
  }

  Future<Product> getProduct(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/products/$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      return Product.fromJson(data);
    }

    throw Exception('Ürün yüklenemedi.');
  }

  Future<List<String>> getCategories() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/products/category-list'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data.map((category) => category.toString()).toList();
    }

    throw Exception('Kategoriler yüklenemedi.');
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/products/category/$category'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      final List<dynamic> productsJson = data['products'];

      return productsJson.map((json) => Product.fromJson(json)).toList();
    }

    throw Exception('Kategori ürünleri yüklenemedi.');
  }
}
