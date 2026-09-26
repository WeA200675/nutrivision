import 'nutrition_catalog.dart';

class NutritionSearchController {
  NutritionSearchController(this.catalog);
  final NutritionCatalog catalog;

  bool isLoading = false;
  String? error;
  List<FoodItem> results = const [];

  Future<void> search(String query) async {
    final normalized = query.trim();
    error = null;
    if (normalized.length < 2) {
      results = const [];
      return;
    }
    isLoading = true;
    try {
      if (RegExp(r'^\d{8,14}$').hasMatch(normalized)) {
        final product = await catalog.findByBarcode(normalized);
        results = product == null ? const [] : [product];
      } else {
        results = await catalog.search(normalized);
      }
    } catch (_) {
      results = const [];
      error = 'Lebensmittel konnten nicht geladen werden.';
    } finally {
      isLoading = false;
    }
  }
}
