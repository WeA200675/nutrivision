import '../diary/meal.dart';

class NutritionStatistics {
  const NutritionStatistics(this.meals);
  final List<Meal> meals;

  double get kcal => _sum((m) => m.kcal);
  double get proteinGrams => _sum((m) => m.proteinGrams);
  double get carbohydrateGrams => _sum((m) => m.carbohydrateGrams);
  double get fatGrams => _sum((m) => m.fatGrams);

  double progress(double value, double goal) {
    if (!goal.isFinite || goal <= 0) return 0;
    final result = value / goal;
    return result.clamp(0, 1).toDouble();
  }

  double _sum(double Function(Meal) value) => meals.fold(0, (sum, meal) => sum + value(meal));
}

class DailyStatistics {
  const DailyStatistics(this.date, this.statistics);
  final DateTime date;
  final NutritionStatistics statistics;
}

List<DailyStatistics> groupByDay(Iterable<Meal> meals) {
  final grouped = <DateTime, List<Meal>>{};
  for (final meal in meals) {
    final day = DateTime(meal.loggedAt.year, meal.loggedAt.month, meal.loggedAt.day);
    grouped.putIfAbsent(day, () => []).add(meal);
  }
  return grouped.entries
      .map((entry) => DailyStatistics(entry.key, NutritionStatistics(List.unmodifiable(entry.value))))
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));
}
