import 'dart:async';
import 'package:flutter/material.dart';
import 'nutrition_catalog.dart';
import 'nutrition_search_controller.dart';
import 'local_food_catalog.dart';
import 'manual_food_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'favorite_food_repository.dart';
import '../ocr/ocr_capture_screen.dart';
import '../rewards/nutri_world.dart';
import '../rewards/reward_events.dart';

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

  Future<void> _toggleFavorite(FoodItem food) async {
    final repository = _favorites;
    if (repository == null) return;
    final wasFavorite = repository.contains(food.name);
    await repository.toggle(food.name);
    if (!mounted) return;
    setState(() {});
    if (!wasFavorite) {
      final prefs = await SharedPreferences.getInstance();
      await RewardService(NutriWorldRepository(prefs)).record(RewardEvent.foodFavorited);
    }
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
              Column(children: [
                OutlinedButton.icon(onPressed: () async { final prefs = await SharedPreferences.getInstance(); if (!mounted) return; final saved = await Navigator.push(context, MaterialPageRoute(builder: (_) => ManualFoodScreen(catalog: LocalFoodCatalog(prefs), barcode: RegExp(r'^\d{8,14}$').hasMatch(_query.text.trim()) ? _query.text.trim() : null))); if (saved == true && mounted) { await _controller.search(_query.text); setState(() {}); } }, icon: const Icon(Icons.add), label: const Text('Eigenes Lebensmittel anlegen')),
                OutlinedButton.icon(onPressed: () async { final prefs = await SharedPreferences.getInstance(); if (!mounted) return; await Navigator.push(context, MaterialPageRoute(builder: (_) => OcrCaptureScreen(catalog: LocalFoodCatalog(prefs), barcode: RegExp(r'^\d{8,14}$').hasMatch(_query.text.trim()) ? _query.text.trim() : null))); await _controller.search(_query.text); if (mounted) setState(() {}); }, icon: const Icon(Icons.document_scanner), label: const Text('Nährwertfoto erkennen')),
              ]),
            Expanded(child: ListView.builder(itemCount: _sortedResults.length, itemBuilder: (context, index) {
              final food = _sortedResults[index];
              return ListTile(
                leading: _ProductImage(url: food.imageUrl),
                title: Text(food.name),
                subtitle: Text('${food.kcalPer100g?.round() ?? '—'} kcal / 100 g'),
                trailing: IconButton(onPressed: () => _toggleFavorite(food), icon: Icon((_favorites?.contains(food.name) ?? false) ? Icons.star : Icons.star_border, color: Colors.amber), tooltip: 'Favorit'),
                onTap: () => Navigator.pop(context, food),
              );
            })),
          ]),
        ),
      );

  List<FoodItem> get _sortedResults {
    final results = [..._controller.results];
    final favorites = _favorites?.load() ?? <String>{};
    results.sort((a, b) => (favorites.contains(b.name) ? 1 : 0).compareTo(favorites.contains(a.name) ? 1 : 0));
    return results;
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({this.url});
  final String? url;
  @override Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: SizedBox(width: 56, height: 56, child: url == null
      ? const ColoredBox(color: Color(0xFFE7F1E5), child: Icon(Icons.restaurant, color: Color(0xFF397A55)))
      : Image.network(url!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFFE7F1E5), child: Icon(Icons.restaurant, color: Color(0xFF397A55)))),
  ));
}

