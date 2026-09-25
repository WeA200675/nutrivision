import 'package:flutter/material.dart';
import 'src/features/diary/diary_screen.dart';

void main() => runApp(const NutriVisionApp());

class NutriVisionApp extends StatelessWidget {
  const NutriVisionApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'NutriVision',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF276A50)),
          useMaterial3: true,
        ),
        home: const DiaryScreen(),
      );
}
