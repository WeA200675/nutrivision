/// Values are always per 100 g; unknown values must stay unknown.
abstract interface class NutritionCatalog {
  Future<List<FoodItem>> search(String query);
  Future<FoodItem?> findByBarcode(String barcode);
}

class FoodItem {
  const FoodItem({
    required this.name,
    required this.kcalPer100g,
    required this.proteinPer100g,
    required this.carbohydratePer100g,
    required this.fatPer100g,
    this.imageUrl,
  });

  final String name;
  final double? kcalPer100g;
  final double? proteinPer100g;
  final double? carbohydratePer100g;
  final double? fatPer100g;
  final String? imageUrl;
}

