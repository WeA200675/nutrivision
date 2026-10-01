import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'nutrition_catalog.dart';

class LocalFoodCatalog {
  LocalFoodCatalog(this.preferences);
  final SharedPreferences preferences;
  static const _key = 'nutrition.local-foods.v1';

  List<_StoredFood> _read() {
    final raw = preferences.getString(_key); if (raw == null) return [];
    try { final data = jsonDecode(raw); if (data is! List) return []; return data.whereType<Map>().map(_StoredFood.fromJson).toList(); } catch (_) { return []; }
  }
  Future<void> save({required String? barcode, required FoodItem food}) async {
    final items = _read()..removeWhere((x) => barcode != null && x.barcode == barcode);
    items.add(_StoredFood(barcode: barcode, food: food));
    final ok = await preferences.setString(_key, jsonEncode(items.map((x) => x.toJson()).toList()));
    if (!ok) throw StateError('Eigenes Lebensmittel konnte nicht gespeichert werden.');
  }
  FoodItem? findByBarcode(String barcode) => _read().where((x) => x.barcode == barcode).map((x) => x.food).firstOrNull;
  List<FoodItem> search(String query) => _read().where((x) => x.food.name.toLowerCase().contains(query.toLowerCase())).map((x) => x.food).toList();
}
class _StoredFood {
  const _StoredFood({required this.barcode, required this.food});
  final String? barcode; final FoodItem food;
  factory _StoredFood.fromJson(Map value) => _StoredFood(barcode: value['barcode'] as String?, food: FoodItem(name: value['name'] as String? ?? '', kcalPer100g: (value['kcal'] as num?)?.toDouble(), proteinPer100g: (value['protein'] as num?)?.toDouble(), carbohydratePer100g: (value['carbs'] as num?)?.toDouble(), fatPer100g: (value['fat'] as num?)?.toDouble()));
  Map<String,Object?> toJson() => {'barcode': barcode, 'name': food.name, 'kcal': food.kcalPer100g, 'protein': food.proteinPer100g, 'carbs': food.carbohydratePer100g, 'fat': food.fatPer100g};
}
extension<T> on Iterable<T> { T? get firstOrNull => isEmpty ? null : first; }
