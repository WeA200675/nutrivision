import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});
  @override State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  final excluded = <String>{};
  static const _preferenceKey = 'recommendations.excluded.v1';
  final items = const [
    ('Hafer-Bowl', 'Haferflocken, Beeren und Joghurt', ['vegetarisch', 'nussfrei'], Icons.breakfast_dining, Colors.orange),
    ('Bunte Gemüsepfanne', 'Paprika, Zucchini, Kichererbsen', ['vegan', 'laktosefrei'], Icons.ramen_dining, Colors.green),
    ('Lachs mit Ofengemüse', 'Lachs, Kartoffeln und Brokkoli', ['proteinreich', 'nussfrei'], Icons.set_meal, Colors.blue),
    ('Joghurt mit Obst', 'Naturjoghurt, Apfel und Zimt', ['vegetarisch', 'schnell'], Icons.icecream, Colors.pink),
  ];
  @override void initState() { super.initState(); _loadPreferences(); }
  Future<void> _loadPreferences() async { final prefs = await SharedPreferences.getInstance(); if (mounted) setState(() => excluded.addAll(prefs.getStringList(_preferenceKey) ?? const [])); }
  Future<void> _toggle(String filter, bool selected) async { setState(() => selected ? excluded.add(filter) : excluded.remove(filter)); final prefs = await SharedPreferences.getInstance(); await prefs.setStringList(_preferenceKey, excluded.toList()); }
  @override Widget build(BuildContext context) {
    final visible = items.where((item) => !item.$3.any(excluded.contains)).toList();
    return Scaffold(appBar: AppBar(title: const Text('Essensideen')), body: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Was möchtest du heute vermeiden?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 10), Wrap(spacing: 8, children: [for (final filter in ['vegetarisch', 'vegan', 'laktosefrei', 'nussfrei']) FilterChip(label: Text(filter), selected: excluded.contains(filter), onSelected: (selected) => _toggle(filter, selected))]),
      const SizedBox(height: 20),
      if (visible.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('Keine Idee passt zu den aktuellen Filtern. Entferne einen Filter, um weitere Vorschläge zu sehen.'))),
      for (final item in visible) Card(child: ListTile(leading: CircleAvatar(backgroundColor: item.$5.withValues(alpha: .18), child: Icon(item.$4, color: item.$5)), title: Text(item.$1), subtitle: Text('${item.$2}\n${item.$3.join(' · ')}'), isThreeLine: true, trailing: const Icon(Icons.arrow_forward_ios, size: 16))),
    ]));
  }
}

