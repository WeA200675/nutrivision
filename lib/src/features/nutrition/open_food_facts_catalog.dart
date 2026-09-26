import 'dart:convert';
import 'package:http/http.dart' as http;
import 'nutrition_catalog.dart';

class OpenFoodFactsCatalog implements NutritionCatalog {
  OpenFoodFactsCatalog({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;
  static const _host = 'world.openfoodfacts.org';

  @override
  Future<List<FoodItem>> search(String query) async {
    final normalized = query.trim();
    if (normalized.length < 2) return [];
    final uri = Uri.https(_host, '/cgi/search.pl', {
      'search_terms': normalized,
      'search_simple': '1',
      'action': 'process',
      'json': '1',
      'page_size': '20',
      'fields': 'product_name,nutriments',
    });
    final response = await _get(uri);
    final products = response['products'];
    if (products is! List) return [];
    return products.whereType<Map>().map(_parse).whereType<FoodItem>().toList();
  }

  @override
  Future<FoodItem?> findByBarcode(String barcode) async {
    final normalized = barcode.trim();
    if (!RegExp(r'^\\d{8,14}$').hasMatch(normalized)) return null;
    final uri = Uri.https(_host, '/api/v2/product/$normalized.json', {
      'fields': 'product_name,nutriments',
    });
    final response = await _get(uri);
    if (response['status'] != 1 || response['product'] is! Map) return null;
    return _parse(response['product'] as Map);
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    final response = await _client.get(uri, headers: {'User-Agent': 'NutriVision/0.1'}).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) throw NutritionNetworkException(response.statusCode);
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) throw const NutritionFormatException();
    return decoded;
  }

  FoodItem? _parse(Map product) {
    final name = product['product_name'];
    final nutrients = product['nutriments'];
    if (name is! String || name.trim().isEmpty || nutrients is! Map) return null;
    return FoodItem(
      name: name.trim(),
      kcalPer100g: _number(nutrients['energy-kcal_100g']),
      proteinPer100g: _number(nutrients['proteins_100g']),
      carbohydratePer100g: _number(nutrients['carbohydrates_100g']),
      fatPer100g: _number(nutrients['fat_100g']),
    );
  }

  double? _number(Object? value) => value is num && value.isFinite ? value.toDouble() : null;
}

class NutritionNetworkException implements Exception {
  const NutritionNetworkException(this.statusCode);
  final int statusCode;
  @override
  String toString() => 'Nährwertdienst antwortete mit HTTP $statusCode.';
}

class NutritionFormatException implements Exception {
  const NutritionFormatException();
  @override
  String toString() => 'Nährwertdienst lieferte ein ungültiges Format.';
}
