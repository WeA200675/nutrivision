import 'nutri_world.dart';
import 'dart:math';
enum RewardEvent { mealLogged, waterLogged, activityCompleted, recipeCreated, foodFavorited, profileCompleted, calorieGoalReached, proteinGoalReached }
extension RewardEventMapping on RewardEvent { WorldTheme get theme => switch(this){RewardEvent.mealLogged=>WorldTheme.garden,RewardEvent.waterLogged=>WorldTheme.pond,RewardEvent.activityCompleted=>WorldTheme.path,RewardEvent.recipeCreated=>WorldTheme.kitchen,RewardEvent.foodFavorited=>WorldTheme.pantry,RewardEvent.profileCompleted=>WorldTheme.tree,RewardEvent.calorieGoalReached=>WorldTheme.garden,RewardEvent.proteinGoalReached=>WorldTheme.tree}; int get points => switch(this){RewardEvent.calorieGoalReached=>3,RewardEvent.proteinGoalReached=>2,_=>1}; }
class RewardResult {
  const RewardResult({required this.successes, required this.specialMoment, this.animation = 'Sternenregen', this.animal = 'Elefant'});
  final int successes;
  final bool specialMoment;
  final String animation;
  final String animal;
}

class RewardService {
  const RewardService(this.repository);
  final NutriWorldRepository repository;
  static const _successKey = 'nutri-world.successes.v1';
  static const _historyKey = 'nutri-world.reward-history.v1';
  static const _animations = ['Sternenregen', 'Konfetti-Sprung', 'Lichtwelle', 'Farbwirbel', 'Goldener Funke', 'Kometenlauf'];
  static const _animals = ['Elefant', 'Giraffe', 'Tiger', 'Kuh', 'Wasserschildkröte'];

  Future<RewardResult> record(RewardEvent event) async {
    await repository.award(event.theme, event.points);
    final current = repository.preferences.getInt(_successKey) ?? 0;
    final successes = current + 1;
    await repository.preferences.setInt(_successKey, successes % 3);
    final history = repository.preferences.getStringList(_historyKey) ?? <String>[];
    final candidates = [for (final animation in _animations) for (final animal in _animals) '$animation|$animal'];
    final available = candidates.where((key) => !history.contains(key)).toList();
    final selected = (available.isNotEmpty ? available : candidates)[Random().nextInt((available.isNotEmpty ? available : candidates).length)];
    final parts = selected.split('|');
    final nextHistory = [...history, selected];
    if (nextHistory.length > 8) nextHistory.removeRange(0, nextHistory.length - 8);
    await repository.preferences.setStringList(_historyKey, nextHistory);
    return RewardResult(successes: successes, specialMoment: successes % 3 == 0, animation: parts[0], animal: parts[1]);
  }
}

