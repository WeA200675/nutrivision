import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'exercise_frames.dart';

class ExercisePlan {
  const ExercisePlan({required this.animal, required this.exercise, required this.reason});
  final String animal;
  final String exercise;
  final String reason;
  Map<String, String> toJson() => {'animal': animal, 'exercise': exercise, 'reason': reason};
  factory ExercisePlan.fromJson(Map value) => ExercisePlan(animal: value['animal'] as String? ?? '', exercise: value['exercise'] as String? ?? '', reason: value['reason'] as String? ?? '');
}

class ExercisePlannerResult {
  const ExercisePlannerResult({required this.exercise, required this.completedCount, required this.plansReady});
  final String exercise;
  final int completedCount;
  final bool plansReady;
}

class ExercisePlanner {
  ExercisePlanner(this.preferences);
  final SharedPreferences preferences;
  static const _countsKey = 'activity.exercise-counts.v1';
  static const _plansKey = 'activity.exercise-plans.v2';
  static const _framesKey = 'activity.exercise-frames.v1';
  static const exercises = ['Kniebeugen', 'Armheben', 'Ausfallschritte', 'Seitbeugen', 'Balance', 'Schulterkreisen', 'Wasserpaddeln', 'Beinheben', 'Rumpfdrehung', 'Wandsitzen'];
  static const animals = ['Elefantin', 'Tiger', 'Giraffe', 'Kuh', 'Wasserschildkröte'];

  Map<String, int> _counts() {
    final raw = preferences.getString(_countsKey);
    if (raw == null) return {};
    try { return (jsonDecode(raw) as Map).map((key, value) => MapEntry(key.toString(), (value as num).toInt())); } catch (_) { return {}; }
  }

  Future<ExercisePlannerResult> record(String exercise) async {
    final counts = _counts();
    counts[exercise] = (counts[exercise] ?? 0) + 1;
    await preferences.setString(_countsKey, jsonEncode(counts));
    final ready = counts.values.any((count) => count >= 2);
    if (ready && preferences.getString(_plansKey) == null) await _planAllAnimals();
    return ExercisePlannerResult(exercise: exercise, completedCount: counts[exercise]!, plansReady: ready);
  }

  List<ExercisePlan> loadPlans() {
    final raw = preferences.getString(_plansKey);
    if (raw == null) return const [];
    try { return (jsonDecode(raw) as List).whereType<Map>().map(ExercisePlan.fromJson).toList(); } catch (_) { return const []; }
  }

  List<ExerciseFrame> loadFrames(ExercisePlan plan) {
    final raw = preferences.getString('$_framesKey.${plan.animal}.${plan.exercise}');
    if (raw == null) return const [];
    return ExerciseFrameGenerator.decode(raw);
  }

  Future<void> _planAllAnimals() async {
    final random = Random();
    final shuffled = [...exercises]..shuffle(random);
    final plans = [for (var i = 0; i < animals.length; i++) ExercisePlan(animal: animals[i], exercise: shuffled[i % shuffled.length], reason: 'Zufällige Auswahl aus dem gemeinsamen Übungskatalog')];
    await preferences.setString(_plansKey, jsonEncode(plans.map((plan) => plan.toJson()).toList()));
    const generator = ExerciseFrameGenerator();
    for (final plan in plans) {
      final frames = generator.generate(animal: plan.animal, exercise: plan.exercise);
      await preferences.setString('$_framesKey.${plan.animal}.${plan.exercise}', ExerciseFrameGenerator.encode(frames));
    }
  }
}
