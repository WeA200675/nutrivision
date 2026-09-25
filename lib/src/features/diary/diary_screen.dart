import 'package:flutter/material.dart';
import 'meal.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final List<Meal> _meals = [];

  double get _totalKcal => _meals.fold(0, (sum, meal) => sum + meal.kcal);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('NutriVision')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Heute', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${_totalKcal.round()} kcal',
                        style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 8),
                    Text('Protein ${_sum((m) => m.proteinGrams).round()} g  ·  '
                        'Kohlenhydrate ${_sum((m) => m.carbohydrateGrams).round()} g  ·  '
                        'Fett ${_sum((m) => m.fatGrams).round()} g'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Mahlzeiten', style: Theme.of(context).textTheme.titleLarge),
            if (_meals.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('Noch keine Mahlzeit eingetragen.'),
              ),
            for (final meal in _meals.reversed)
              ListTile(
                title: Text(meal.name),
                subtitle: Text('${meal.grams.round()} g'),
                trailing: Text('${meal.kcal.round()} kcal'),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addMeal,
          icon: const Icon(Icons.add),
          label: const Text('Mahlzeit'),
        ),
      );

  double _sum(double Function(Meal) value) =>
      _meals.fold(0, (sum, meal) => sum + value(meal));

  Future<void> _addMeal() async {
    final meal = await showDialog<Meal>(
      context: context,
      builder: (context) => const _MealDialog(),
    );
    if (meal != null && mounted) setState(() => _meals.add(meal));
  }
}

class _MealDialog extends StatefulWidget {
  const _MealDialog();

  @override
  State<_MealDialog> createState() => _MealDialogState();
}

class _MealDialogState extends State<_MealDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _grams = TextEditingController();
  final _kcal = TextEditingController();
  final _protein = TextEditingController();
  final _carbs = TextEditingController();
  final _fat = TextEditingController();

  @override
  void dispose() {
    for (final controller in [_name, _grams, _kcal, _protein, _carbs, _fat]) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _number(String label, TextEditingController controller) => TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (value) {
          final number = double.tryParse((value ?? '').replaceAll(',', '.'));
          return number == null || !number.isFinite || number < 0
              ? 'Bitte eine Zahl ab 0 eingeben'
              : null;
        },
      );

  double _value(TextEditingController controller) =>
      double.parse(controller.text.replaceAll(',', '.'));

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Mahlzeit eintragen'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? 'Bitte Namen eingeben'
                      : null,
                ),
                _number('Menge (g)', _grams),
                _number('Kalorien (kcal)', _kcal),
                _number('Protein (g)', _protein),
                _number('Kohlenhydrate (g)', _carbs),
                _number('Fett (g)', _fat),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              Navigator.pop(
                context,
                Meal(
                  name: _name.text.trim(),
                  grams: _value(_grams),
                  kcal: _value(_kcal),
                  proteinGrams: _value(_protein),
                  carbohydrateGrams: _value(_carbs),
                  fatGrams: _value(_fat),
                  loggedAt: DateTime.now(),
                ),
              );
            },
            child: const Text('Speichern'),
          ),
        ],
      );
}
