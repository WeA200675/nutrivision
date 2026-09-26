import '../nutrition/nutrition_catalog.dart';

class NutritionCalculator {
  const NutritionCalculator();

  NutritionTotals forPortion(FoodItem food, double grams) {
    if (!grams.isFinite || grams < 0) {
      throw ArgumentError.value(grams, 'grams', 'muss >= 0 sein');
    }
    final factor = grams / 100;
    return NutritionTotals(
      kcal: _scale(food.kcalPer100g, factor),
      proteinGrams: _scale(food.proteinPer100g, factor),
      carbohydrateGrams: _scale(food.carbohydratePer100g, factor),
      fatGrams: _scale(food.fatPer100g, factor),
    );
  }

  double? _scale(double? value, double factor) => value == null ? null : value * factor;
}

class NutritionTotals {
  const NutritionTotals({this.kcal, this.proteinGrams, this.carbohydrateGrams, this.fatGrams});
  final double? kcal;
  final double? proteinGrams;
  final double? carbohydrateGrams;
  final double? fatGrams;
}
