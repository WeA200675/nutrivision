import 'package:flutter/material.dart';
import 'meal_analyzer.dart';
import 'photo_source.dart';

class PhotoAnalysisScreen extends StatefulWidget {
  const PhotoAnalysisScreen({super.key, required this.source, required this.analyzer});
  final PhotoSource source;
  final MealAnalyzer analyzer;

  @override
  State<PhotoAnalysisScreen> createState() => _PhotoAnalysisScreenState();
}

class _PhotoAnalysisScreenState extends State<PhotoAnalysisScreen> {
  bool _busy = false;
  String? _error;
  List<MealSuggestion> _suggestions = const [];

  Future<void> _choose(Future<List<int>?> Function() getPhoto) async {
    setState(() { _busy = true; _error = null; _suggestions = const []; });
    try {
      final bytes = await getPhoto();
      if (bytes == null || bytes.isEmpty) { setState(() => _error = 'Kein Bild ausgewählt.'); return; }
      final suggestions = await widget.analyzer.analyzePhoto(bytes);
      if (mounted) setState(() => _suggestions = suggestions);
    } catch (_) {
      if (mounted) setState(() => _error = 'Das Foto konnte nicht analysiert werden.');
    } finally { if (mounted) setState(() => _busy = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Fotoanalyse')),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      const Text('Erkannte Lebensmittel sind Vorschläge. Prüfe Menge und Namen vor dem Speichern.'),
      const SizedBox(height: 16),
      Row(children: [Expanded(child: FilledButton.icon(onPressed: _busy ? null : () => _choose(widget.source.capture), icon: const Icon(Icons.camera_alt), label: const Text('Kamera'))), const SizedBox(width: 12), Expanded(child: OutlinedButton.icon(onPressed: _busy ? null : () => _choose(widget.source.pickFromGallery), icon: const Icon(Icons.photo_library), label: const Text('Galerie')))]),
      if (_busy) const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()),
      if (_error != null) Padding(padding: const EdgeInsets.all(16), child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
      Expanded(child: ListView.builder(itemCount: _suggestions.length, itemBuilder: (context, index) { final item = _suggestions[index]; return ListTile(title: Text(item.name), subtitle: Text('geschätzt ${item.estimatedGrams.round()} g')); })),
      if (_suggestions.isNotEmpty) FilledButton(onPressed: () => Navigator.pop(context, _suggestions), child: const Text('Vorschläge übernehmen')),
    ])),
  );
}
