import 'package:shared_preferences/shared_preferences.dart';
class ActivityRepository {
  ActivityRepository(this.preferences); final SharedPreferences preferences;
  String _key(DateTime d) => 'activity.${d.year}-${d.month}-${d.day}';
  bool isDone(DateTime date) => preferences.getBool(_key(date)) ?? false;
  Future<void> setDone(DateTime date, bool done) async { final ok=await preferences.setBool(_key(date),done); if(!ok) throw StateError('Aktivitätsstatus konnte nicht gespeichert werden.'); }
}
