import 'dart:async';
import 'package:flutter/material.dart';
import 'nutrition_catalog.dart';
import 'nutrition_search_controller.dart';
import 'local_food_catalog.dart';
import 'manual_food_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'favorite_food_repository.dart';

class NutritionSearchScreen extends StatefulWidget {
  const NutritionSearchScreen({super.key, required this.catalog});
  final NutritionCatalog catalog;

  @override
  State<NutritionSearchScreen> createState() => _NutritionSearchScreenState();
}

class _NutritionSearchScreenState extends State<NutritionSearchScreen> {
  late final NutritionSearchController _controller = NutritionSearchController(widget.catalog);
  FavoriteFoodRepository? _favorites;
  final _query = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() { _debounce?.cancel(); _query.dispose(); super.dispose(); }

  @override
  void initState() { super.initState(); SharedPreferences.getInstance().then((p) { if (mounted) setState(() => _favorites = FavoriteFoodRepository(p)); }); }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      if (mounted) setState(() => _controller.isLoading = value.trim().length >= 2);
      await _controller.search(value);
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Lebensmittel suchen')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            TextField(controller: _query, onChanged: _onChanged, decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'z. B. Haferflocken')),
            const SizedBox(height: 16),
            if (_controller.isLoading) const LinearProgressIndicator(),
            if (_controller.error != null) Text(_controller.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            if (!_controller.isLoading && _query.text.trim().length >= 2 && _controller.results.isEmpty)
              OutlinedButton.icon(onPressed: () async { final prefs = await SharedPreferences.getInstance(); if (!mounted) return; final saved = await Navigator.push(context, MaterialPageRoute(builder: (_) => ManualFoodScreen(catalog: LocalFoodCatalog(prefs), barcode: RegExp(r'^\d{8,14}$').hasMatch(_query.text.trim()) ? _query.text.trim() : null))); if (saved == true && mounted) { await _controller.search(_query.text); setState(() {}); } }, icon: const Icon(Icons.add), label: const Text('Eigenes Lebensmittel anlegen')),
            Expanded(child: ListView.builder(itemCount: _controller.results.length, itemBuilder: (context, index) {
              final food = _controller.results[index];
              return ListTile(title: Text(food.name), subtitle: Text('${food.kcalPer100g?.round() ?? '—'} kcal / 100 g'), onTap: () => Navigator.pop(context, food));
            })),
          ]),
        ),
      );
}
