import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/features/diary/meal_repository.dart';
import 'src/features/diary/diary_screen.dart';
import 'src/features/nutrition/open_food_facts_catalog.dart';
import 'src/features/nutrition/nutrition_catalog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(NutriVisionApp(repository: LocalMealRepository(preferences), catalog: OpenFoodFactsCatalog()));
}

class NutriVisionApp extends StatelessWidget {
  const NutriVisionApp({super.key, required this.repository, required this.catalog});

  final MealRepository repository;
  final NutritionCatalog catalog;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'NutriVision',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D52),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF3FAF4),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFDDF2DF),
            foregroundColor: Color(0xFF174D31),
            centerTitle: false,
          ),
          cardTheme: const CardThemeData(
            color: Colors.white,
            elevation: 1,
            margin: EdgeInsets.zero,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF0F9F1),
            prefixIconColor: const Color(0xFF2E7D52),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF2E7D52), width: 2),
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFFFC928),
            foregroundColor: Color(0xFF174D31),
          ),
          useMaterial3: true,
        ),
        home: DiaryScreen(repository: repository, catalog: catalog),
      );
}
