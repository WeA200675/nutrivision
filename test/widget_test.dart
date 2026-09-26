import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('NutriVision smoke test', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('NutriVision'))));
    expect(find.text('NutriVision'), findsOneWidget);
  });
}
