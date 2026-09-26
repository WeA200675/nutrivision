import 'package:shared_preferences/shared_preferences.dart';
class WaterRepository {
  WaterRepository(this.preferences); final SharedPreferences preferences;
  String _key(DateTime d) => 'water.${d.year}-${d.month}-${d.day}';
  int load(DateTime date) => preferences.getInt(_key(date)) ?? 0;
  Future<void> add(DateTime date, {int milliliters = 250}) async {
    if (milliliters <= 0) throw ArgumentError.value(milliliters, 'milliliters');
    final key=_key(date); final ok=await preferences.setInt(key, load(date)+milliliters); if(!ok) throw StateError('Trinkmenge konnte nicht gespeichert werden.');
  }
}
