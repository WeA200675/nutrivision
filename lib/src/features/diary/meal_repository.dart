import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'meal.dart';

abstract interface class MealRepository {
  Future<List<Meal>> load();
  Future<void> save(List<Meal> meals);
}

class LocalMealRepository implements MealRepository {
  LocalMealRepository(this._preferences);
  static const _key = 'diary.meals.v1';
  final SharedPreferences _preferences;

  @override
  Future<List<Meal>> load() async {
    final raw = _preferences.getString(_key);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded.whereType<Map>().map(_fromJson).toList();
    } on FormatException {
      return [];
    }
  }

  @override
  Future<void> save(List<Meal> meals) async {
    final payload = meals.map(_toJson).toList(growable: false);
    final ok = await _preferences.setString(_key, jsonEncode(payload));
    if (!ok) throw StateError('Mahlzeiten konnten nicht gespeichert werden.');
  }

  Meal _fromJson(Map value) => Meal(
        name: _string(value['name']),
        grams: _number(value['grams']),
        kcal: _number(value['kcal']),
        proteinGrams: _number(value['proteinGrams']),
        carbohydrateGrams: _number(value['carbohydrateGrams']),
        fatGrams: _number(value['fatGrams']),
        loggedAt: DateTime.tryParse(_string(value['loggedAt'])) ?? DateTime.now(),
        type: MealType.values.firstWhere((item) => item.name == value['type'], orElse: () => MealType.snack),
      );

  Map<String, Object> _toJson(Meal meal) => {
        'name': meal.name,
        'grams': meal.grams,
        'kcal': meal.kcal,
        'proteinGrams': meal.proteinGrams,
        'carbohydrateGrams': meal.carbohydrateGrams,
        'fatGrams': meal.fatGrams,
        'loggedAt': meal.loggedAt.toIso8601String(),
        'type': meal.type.name,
      };

  String _string(Object? value) => value is String ? value : '';
  double _number(Object? value) => value is num && value.isFinite ? value.toDouble() : 0;
}
