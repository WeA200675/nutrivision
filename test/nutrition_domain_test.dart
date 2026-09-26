import 'package:flutter_test/flutter_test.dart';
import 'package:nutrivision/src/features/diary/meal.dart';
import 'package:nutrivision/src/features/diary/nutrition_calculator.dart';
import 'package:nutrivision/src/features/nutrition/nutrition_catalog.dart';
import 'package:nutrivision/src/features/stats/statistics.dart';
import 'package:nutrivision/src/features/profile/user_profile.dart';
import 'package:nutrivision/src/features/ocr/nutrition_ocr_parser.dart';

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

  test('calculates a safe calorie target for healthy weight loss', () {
    const profile = UserProfile(heightCm: 170, weightKg: 80, age: 40, sex: BiologicalSex.female, activityFactor: 1.4, targetLossKgPerWeek: 0.5);
    expect(profile.bmi, closeTo(27.68, .01));
    expect(profile.safeDailyCalories, greaterThanOrEqualTo(1200));
    expect(profile.safeDailyCalories, lessThan(profile.maintenanceCalories));
  });

  test('recognizes German and English nutrition labels', () {
    const text = 'Energie 420 kcal Protein 12 g Kohlenhydrate 55 g Fett 8 g Zucker 10 g Salz 0,4 g';
    final values = NutritionOcrParser().parse(text);
    expect(values.kcal, 420);
    expect(values.protein, 12);
    expect(values.carbs, 55);
    expect(values.fat, 8);
    expect(values.salt, .4);
  });
}

