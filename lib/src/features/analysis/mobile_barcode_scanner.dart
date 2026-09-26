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
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Barcode scannen')),
    body: MobileScanner(controller: _controller, onDetect: (capture) {
      if (_handled) return;
      final code = capture.barcodes.map((b) => b.rawValue).whereType<String>().firstWhere((v) => BarcodeValidation.isSupported(v), orElse: () => '');
      if (code.isEmpty) return;
      _handled = true;
      _controller.stop();
      Navigator.pop(context, code);
    }),
  );
}
