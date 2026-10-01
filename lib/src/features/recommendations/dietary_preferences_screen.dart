import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DietaryPreferencesScreen extends StatefulWidget {
  const DietaryPreferencesScreen({super.key});
  @override State<DietaryPreferencesScreen> createState() => _DietaryPreferencesScreenState();
}

class _DietaryPreferencesScreenState extends State<DietaryPreferencesScreen> {
  static const key = 'recommendations.excluded.v1';
  final selected = <String>{};
  final options = const ['nussfrei', 'laktosefrei', 'glutenfrei', 'fischfrei', 'fleischfrei', 'zuckerarm', 'vegetarisch', 'vegan'];
  @override void initState() { super.initState(); SharedPreferences.getInstance().then((p) { if (mounted) setState(() => selected.addAll(p.getStringList(key) ?? const [])); }); }
  Future<void> save() async { final p = await SharedPreferences.getInstance(); await p.setStringList(key, selected.toList()); if (mounted) Navigator.pop(context, true); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Allergien & Vorlieben')), body: ListView(padding: const EdgeInsets.all(16), children: [const Text('Wähle alles aus, was du vermeiden möchtest.', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)), const SizedBox(height: 16), Wrap(spacing: 8, runSpacing: 8, children: [for (final option in options) FilterChip(label: Text(option), selected: selected.contains(option), onSelected: (value) => setState(() => value ? selected.add(option) : selected.remove(option)))]), const SizedBox(height: 24), const Text('Hinweis: Die Angaben helfen bei Empfehlungen, ersetzen aber keine medizinische Beratung.'), const SizedBox(height: 20), FilledButton.icon(onPressed: save, icon: const Icon(Icons.save), label: const Text('Auswahl speichern'))]));
}

