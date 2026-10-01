
/// Future implementations can analyze photos without changing the diary UI.
abstract interface class MealAnalyzer {
  Future<List<MealSuggestion>> analyzePhoto(List<int> imageBytes);
}

class MealSuggestion {
  const MealSuggestion({required this.name, required this.estimatedGrams});

  final String name;
  final double estimatedGrams;
}

