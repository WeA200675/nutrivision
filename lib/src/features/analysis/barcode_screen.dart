import 'package:flutter/material.dart';
import 'barcode_scanner.dart';
import '../nutrition/nutrition_catalog.dart';

class BarcodeScreen extends StatefulWidget {
  const BarcodeScreen({super.key, required this.scanner, required this.catalog});
  final BarcodeScanner scanner;
  final NutritionCatalog catalog;

  @override
  State<BarcodeScreen> createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends State<BarcodeScreen> {
  bool _busy = false;
  String? _message;

  Future<void> _scan() async {
    setState(() { _busy = true; _message = null; });
    try {
      final code = await widget.scanner.scan();
      if (!mounted) return;
      if (code == null || code.trim().isEmpty) { setState(() => _message = 'Kein Barcode erkannt.'); return; }
      if (!BarcodeValidation.isSupported(code)) { setState(() => _message = 'Dieser Barcode wird nicht unterstützt.'); return; }
      final food = await widget.catalog.findByBarcode(code);
      if (!mounted) return;
      if (food == null) { setState(() => _message = 'Produkt nicht gefunden.'); return; }
      Navigator.pop(context, food);
    } catch (_) {
      if (mounted) setState(() => _message = 'Barcode konnte nicht verarbeitet werden.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Barcode scannen')),
        body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.qr_code_scanner, size: 88),
          const SizedBox(height: 16),
          const Text('Halte den Barcode in den Kamerarahmen.'),
          const SizedBox(height: 16),
          if (_message != null) Text(_message!, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: _busy ? null : _scan, icon: const Icon(Icons.camera_alt), label: Text(_busy ? 'Suche …' : 'Scan starten')),
        ]))),
      );
}
