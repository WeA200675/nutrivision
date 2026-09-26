import 'package:flutter/material.dart';
import '../diary/meal_repository.dart';
import 'statistics.dart';
import '../widgets/nutrition_ring.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key, required this.repository});
  final MealRepository repository;
  @override State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool loading = true;
  NutritionStatistics stats = const NutritionStatistics([]);
  int days = 0;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final meals = await widget.repository.load();
    if (mounted) setState(() { stats = NutritionStatistics(meals); days = groupByDay(meals).length; loading = false; });
  }
  @override Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 12, children: [
          NutritionRing(label: 'Kalorien', value: stats.kcal, goal: 2000, unit: ' kcal', color: Colors.deepOrange),
          NutritionRing(label: 'Protein', value: stats.proteinGrams, goal: 120, unit: ' g', color: Colors.redAccent),
          NutritionRing(label: 'Kohlenhydrate', value: stats.carbohydrateGrams, goal: 220, unit: ' g', color: Colors.lightBlue),
          NutritionRing(label: 'Fett', value: stats.fatGrams, goal: 65, unit: ' g', color: Colors.amber),
        ]),
        Card(child: ListTile(title: const Text('Erfasste Tage'), trailing: Text('$days', style: Theme.of(context).textTheme.titleLarge))),
      ]),
    );
  }
}

