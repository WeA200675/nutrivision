enum MealType { breakfast, lunch, dinner, snack }

class Meal {
  const Meal({
    required this.name,
    required this.grams,
    required this.kcal,
    required this.proteinGrams,
    required this.carbohydrateGrams,
    required this.fatGrams,
    required this.loggedAt,
    this.type = MealType.snack,
  });

  final String name;
  final double grams;
  final double kcal;
  final double proteinGrams;
  final double carbohydrateGrams;
  final double fatGrams;
  final DateTime loggedAt;
  final MealType type;
}
