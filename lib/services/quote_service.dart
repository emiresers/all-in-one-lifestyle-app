import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/quote.dart';

class QuoteService {
  static const String _baseUrl = 'https://dummyjson.com';

  Future<List<Quote>> getQuotes() async {
    final response = await http.get(Uri.parse('$_baseUrl/quotes'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List<dynamic> quotes = data['quotes'];

      return quotes.map((json) => Quote.fromJson(json)).toList();
    }

    throw Exception('Quotes yüklenemedi.');
  }

  Future<Quote> getQuote(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/quotes/$id'));

    if (response.statusCode == 200) {
      return Quote.fromJson(jsonDecode(response.body));
    }

    throw Exception('Quote yüklenemedi.');
  }
}
