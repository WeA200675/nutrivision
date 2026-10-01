import '../nutrition/nutrition_catalog.dart';

class RecipeIngredient {
  const RecipeIngredient({required this.food, required this.grams});
  final FoodItem food;
  final double grams;
}

class Recipe {
  const Recipe({required this.name, required this.servings, required this.ingredients});
  final String name;
  final int servings;
  final List<RecipeIngredient> ingredients;

  List<RecipeIngredient> portion(int requestedServings) {
    if (requestedServings < 1 || servings < 1) throw ArgumentError('Portion muss mindestens 1 sein.');
    final factor = requestedServings / servings;
    return ingredients.map((i) => RecipeIngredient(food: i.food, grams: i.grams * factor)).toList(growable: false);
  }
}
