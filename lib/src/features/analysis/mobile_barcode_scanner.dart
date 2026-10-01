import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'barcode_scanner.dart';

class MobileBarcodeScanner implements BarcodeScanner {
  @override
  Future<String?> scan() async => null;
}

class BarcodeCapturePage extends StatefulWidget {
  const BarcodeCapturePage({super.key});
  @override State<BarcodeCapturePage> createState() => _BarcodeCapturePageState();
}

class _BarcodeCapturePageState extends State<BarcodeCapturePage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;
  bool _scanning = false;
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  Future<void> _toggleScan() async {
    if (_scanning) { await _controller.stop(); } else { await _controller.start(); }
    if (mounted) setState(() => _scanning = !_scanning);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Barcode scannen')),
    body: Stack(children: [MobileScanner(controller: _controller, onDetect: (capture) {
      if (_handled) return;
      final code = capture.barcodes.map((b) => b.rawValue).whereType<String>().firstWhere((v) => BarcodeValidation.isSupported(v), orElse: () => '');
      if (code.isEmpty) return;
      _handled = true;
      _controller.stop();
      Navigator.pop(context, code);
    }), Positioned(left: 24, right: 24, bottom: 32, child: FilledButton.icon(onPressed: _toggleScan, icon: Icon(_scanning ? Icons.pause : Icons.qr_code_scanner), label: Text(_scanning ? 'Scan pausieren' : 'Scan starten')))]),
  );
}
