import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/cart.dart';

class CartService {
  static const String _baseUrl = 'https://dummyjson.com';

  // Kullanıcının sepetlerini getirir
  Future<List<Cart>> getUserCarts(int userId) async {
    final response = await http.get(Uri.parse('$_baseUrl/carts/user/$userId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      final List<dynamic> cartsJson = data['carts'];

      return cartsJson.map((json) => Cart.fromJson(json)).toList();
    }

    throw Exception('Sepetler yüklenemedi.');
  }

  // Sepete ürün ekler
  Future<Map<String, dynamic>> addToCart({
    required int userId,
    required int productId,
    int quantity = 1,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/carts/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'products': [
          {'id': productId, 'quantity': quantity},
        ],
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Ürün sepete eklenemedi.');
  }

  Future<Map<String, dynamic>> updateCart({
    required int cartId,
    required int productId,
    required int quantity,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/carts/$cartId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'merge': true,
        'products': [
          {'id': productId, 'quantity': quantity},
        ],
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Sepet güncellenemedi.');
  }

  Future<Map<String, dynamic>> deleteCart(int cartId) async {
    final response = await http.delete(Uri.parse('$_baseUrl/carts/$cartId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Sepet silinemedi.');
  }
}
