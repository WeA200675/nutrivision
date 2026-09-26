import 'package:flutter_test/flutter_test.dart';
import 'package:nutrivision/src/features/diary/meal.dart';
import 'package:nutrivision/src/features/diary/nutrition_calculator.dart';
import 'package:nutrivision/src/features/nutrition/nutrition_catalog.dart';
import 'package:nutrivision/src/features/stats/statistics.dart';

void main() {
  test('scales nutrition values to a portion', () {
    const food = FoodItem(name: 'Haferflocken', kcalPer100g: 370, proteinPer100g: 13, carbohydratePer100g: 60, fatPer100g: 7);
    final result = const NutritionCalculator().forPortion(food, 50);
    expect(result.kcal, 185);
    expect(result.proteinGrams, 6.5);
  });

  test('groups meals by calendar day', () {
    final meals = [
      Meal(name: 'A', grams: 100, kcal: 200, proteinGrams: 10, carbohydrateGrams: 20, fatGrams: 5, loggedAt: DateTime(2026, 1, 2, 8)),
      Meal(name: 'B', grams: 100, kcal: 300, proteinGrams: 20, carbohydrateGrams: 30, fatGrams: 10, loggedAt: DateTime(2026, 1, 2, 19)),
    ];
    final days = groupByDay(meals);
    expect(days, hasLength(1));
    expect(days.single.statistics.kcal, 500);
  });
}
