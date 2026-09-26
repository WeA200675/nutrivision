import 'package:flutter/material.dart';
import 'meal.dart';
import 'meal_repository.dart';
import '../stats/goals.dart';
import '../stats/statistics.dart';
import '../nutrition/nutrition_catalog.dart';
import '../nutrition/nutrition_search_screen.dart';
import '../analysis/mobile_barcode_scanner.dart';
import 'nutrition_calculator.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key, required this.repository, required this.catalog});

  final MealRepository repository;
  final NutritionCatalog catalog;

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final List<Meal> _meals = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _meals.addAll(await widget.repository.load());
    } catch (_) {
      _error = 'Mahlzeiten konnten nicht geladen werden.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double get _totalKcal => NutritionStatistics(_meals).kcal;
  static const _goals = NutritionGoals(kcal: 2000, proteinGrams: 120);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [IconButton(onPressed: _openBarcode, icon: const Icon(Icons.qr_code_scanner), tooltip: 'Barcode scannen'), IconButton(onPressed: _openSearch, icon: const Icon(Icons.search), tooltip: 'Lebensmittel suchen')],
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🌻', style: TextStyle(fontSize: 25)),
              SizedBox(width: 8),
              Text('NutriVision'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_error != null)
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            Row(
              children: [
                Icon(Icons.wb_sunny, color: Theme.of(context).colorScheme.secondary),
                const SizedBox(width: 8),
                Text('Heute', style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${_totalKcal.round()} / ${_goals.kcal.round()} kcal',
                        style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        minHeight: 10,
                        value: NutritionStatistics(_meals).progress(_totalKcal, _goals.kcal),
                        backgroundColor: const Color(0xFFE0F0E2),
                      ),
                    ),
                    const SizedBox(height: 10),
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
              Dismissible(
                key: ObjectKey(meal),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.onErrorContainer),
                ),
                confirmDismiss: (_) => _confirmDelete(meal),
                onDismissed: (_) => _deleteMeal(meal),
                child: ListTile(
                  title: Text(meal.name),
                  subtitle: Text('${_label(meal.type)} · ${meal.grams.round()} g'),
                  trailing: Text('${meal.kcal.round()} kcal'),
                ),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addMeal,
          icon: const Icon(Icons.add),
          label: const Text('Mahlzeit'),
        ),
      );

  String _label(MealType type) => switch (type) { MealType.breakfast => 'Frühstück', MealType.lunch => 'Mittagessen', MealType.dinner => 'Abendessen', MealType.snack => 'Snack' };

  double _sum(double Function(Meal) value) =>
      _meals.fold(0, (sum, meal) => sum + value(meal));

  Future<bool> _confirmDelete(Meal meal) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mahlzeit löschen?'),
        content: Text('„${meal.name}“ wird aus dem Tagebuch entfernt.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Löschen')),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _deleteMeal(Meal meal) async {
    setState(() => _meals.remove(meal));
    try {
      await widget.repository.save(_meals);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _meals.add(meal);
        _error = 'Mahlzeit konnte nicht gelöscht werden.';
      });
    }
  }

  Future<void> _openBarcode() async {
    final code = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => const BarcodeCapturePage()));
    if (code == null || !mounted) return;
    try {
      final food = await widget.catalog.findByBarcode(code);
      if (!mounted) return;
      if (food == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produkt nicht gefunden.'))); return; }
      final meal = await showDialog<Meal>(context: context, builder: (_) => _FoodPortionDialog(food: food));
      if (meal != null && mounted) { setState(() => _meals.add(meal)); await widget.repository.save(_meals); }
    } catch (_) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Barcode konnte nicht verarbeitet werden.'))); }
  }

  Future<void> _openSearch() async {
    final food = await Navigator.push<FoodItem>(context, MaterialPageRoute(builder: (_) => NutritionSearchScreen(catalog: widget.catalog)));
    if (food == null || !mounted) return;
    final meal = await showDialog<Meal>(context: context, builder: (_) => _FoodPortionDialog(food: food));
    if (meal != null && mounted) { setState(() => _meals.add(meal)); await widget.repository.save(_meals); }
  }

  Future<void> _addMeal() async {
    final meal = await showDialog<Meal>(
      context: context,
      builder: (context) => const _MealDialog(),
    );
    if (meal != null && mounted) {
      setState(() => _meals.add(meal));
      try {
        await widget.repository.save(_meals);
      } catch (_) {
        if (mounted) setState(() => _error = 'Mahlzeit konnte nicht gespeichert werden.');
      }
    }
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
  MealType _type = MealType.snack;
  DateTime _date = DateTime.now();

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
                ListTile(leading: const Icon(Icons.event), title: Text('${_date.day.toString().padLeft(2, '0')}.${_date.month.toString().padLeft(2, '0')}.${_date.year}'), trailing: TextButton(onPressed: () async { final picked = await showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 365)), initialDate: _date); if (picked != null) setState(() => _date = DateTime(picked.year, picked.month, picked.day, DateTime.now().hour, DateTime.now().minute)); }, child: const Text('Ändern'))),
                DropdownButtonFormField<MealType>(value: _type, decoration: const InputDecoration(labelText: 'Mahlzeitentyp'), items: const [DropdownMenuItem(value: MealType.breakfast, child: Text('Frühstück')), DropdownMenuItem(value: MealType.lunch, child: Text('Mittagessen')), DropdownMenuItem(value: MealType.dinner, child: Text('Abendessen')), DropdownMenuItem(value: MealType.snack, child: Text('Snack'))], onChanged: (value) => setState(() => _type = value ?? MealType.snack)),
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
                  loggedAt: _date,
                  type: _type,
                ),
              );
            },
            child: const Text('Speichern'),
          ),
        ],
      );
}


class _FoodPortionDialog extends StatefulWidget {
  const _FoodPortionDialog({required this.food});
  final FoodItem food;
  @override State<_FoodPortionDialog> createState() => _FoodPortionDialogState();
}
class _FoodPortionDialogState extends State<_FoodPortionDialog> {
  final _grams = TextEditingController(text: '100');
  @override void dispose() { _grams.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) { final grams = double.tryParse(_grams.text.replaceAll(',', '.')) ?? 100; final totals = const NutritionCalculator().forPortion(widget.food, grams < 0 ? 0 : grams); return AlertDialog(title: Text(widget.food.name), content: TextField(controller: _grams, onChanged: (_) => setState(() {}), keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: 'Menge (g)', helperText: '${totals.kcal?.round() ?? '—'} kcal')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')), FilledButton(onPressed: () { if (grams <= 0) return; Navigator.pop(context, Meal(name: widget.food.name, grams: grams, kcal: totals.kcal ?? 0, proteinGrams: totals.proteinGrams ?? 0, carbohydrateGrams: totals.carbohydrateGrams ?? 0, fatGrams: totals.fatGrams ?? 0, loggedAt: DateTime.now())); }, child: const Text('Übernehmen'))]); }
}
