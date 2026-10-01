import 'nutrition_catalog.dart';
import 'local_food_catalog.dart';

class MultiSourceCatalog implements NutritionCatalog {
  MultiSourceCatalog({required this.local, required this.remote});
  final LocalFoodCatalog local;
  final NutritionCatalog remote;
  @override Future<List<FoodItem>> search(String query) async {
    final localItems = local.search(query); try { return [...localItems, ...await remote.search(query)]; } catch (_) { return localItems; }
  }
  @override Future<FoodItem?> findByBarcode(String barcode) async {
    final own = local.findByBarcode(barcode); if (own != null) return own;
    try { return await remote.findByBarcode(barcode); } catch (_) { return null; }
  }
}
