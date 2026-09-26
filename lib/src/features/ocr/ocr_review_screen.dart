import 'package:flutter/material.dart';
import 'nutrition_ocr_parser.dart';
import '../nutrition/local_food_catalog.dart';
import '../nutrition/nutrition_catalog.dart';

class OcrReviewScreen extends StatefulWidget {
  const OcrReviewScreen({super.key, required this.rawText, this.catalog, this.barcode});
  final String rawText;
  final LocalFoodCatalog? catalog;
  final String? barcode;
  @override State<OcrReviewScreen> createState() => _OcrReviewScreenState();
}

class _OcrReviewScreenState extends State<OcrReviewScreen> {
  late final NutritionOcrValues values;
  final fields = <String, TextEditingController>{};
  final name = TextEditingController();
  final barcode = TextEditingController();

  @override void initState() {
    super.initState();
    values = NutritionOcrParser().parse(widget.rawText);
    barcode.text = widget.barcode ?? '';
    for (final entry in {'kcal': values.kcal, 'kj': values.kj, 'protein': values.protein, 'carbs': values.carbs, 'fat': values.fat, 'sugar': values.sugar, 'salt': values.salt}.entries) {
      fields[entry.key] = TextEditingController(text: entry.value?.toString() ?? '');
    }
  }
  @override void dispose() { name.dispose(); barcode.dispose(); for (final c in fields.values) c.dispose(); super.dispose(); }
  double? _number(String key) => double.tryParse(fields[key]!.text.replaceAll(',', '.'));

  Future<void> _saveToCatalog() async {
    final kcal = _number('kcal'), protein = _number('protein'), carbs = _number('carbs'), fat = _number('fat');
    if (widget.catalog == null || name.text.trim().isEmpty || kcal == null || protein == null || carbs == null || fat == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name und die vier Hauptwerte werden benötigt.')));
      return;
    }
    await widget.catalog!.save(barcode: barcode.text.trim().isEmpty ? null : barcode.text.trim(), food: FoodItem(name: name.text.trim(), kcalPer100g: kcal, proteinPer100g: protein, carbohydratePer100g: carbs, fatPer100g: fat));
    if (mounted) Navigator.pop(context, true);
  }

  @override Widget build(BuildContext context) {
    final recognized = fields.values.where((x) => x.text.trim().isNotEmpty).length;
    return Scaffold(appBar: AppBar(title: const Text('Nährwerte prüfen')), body: ListView(padding: const EdgeInsets.all(16), children: [
      Text(recognized == 0 ? 'Keine Werte sicher erkannt. Bitte alle Angaben manuell prüfen.' : '$recognized von ${fields.length} Werten erkannt. Bitte vor dem Speichern prüfen.', style: TextStyle(color: recognized == 0 ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8), const Text('Die Werte beziehen sich auf 100 g. Dezimalwerte können korrigiert werden.'),
      if (widget.catalog != null) ...[_field('Produktname', name, false), _field('Barcode (optional)', barcode, false)],
      for (final entry in fields.entries) _field('${entry.key} / 100 g', entry.value, true),
      const SizedBox(height: 16), FilledButton(onPressed: widget.catalog == null ? () => Navigator.pop(context, fields.map((k, v) => MapEntry(k, _number(k)))) : _saveToCatalog, child: Text(widget.catalog == null ? 'Werte übernehmen' : 'Produkt speichern')),
    ]));
  }
  Widget _field(String label, TextEditingController controller, bool numeric) => Padding(padding: const EdgeInsets.only(top: 10), child: TextField(controller: controller, keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text, decoration: InputDecoration(labelText: label)));
}

