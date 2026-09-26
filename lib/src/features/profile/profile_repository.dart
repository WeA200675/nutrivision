import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_profile.dart';
class ProfileRepository {
  ProfileRepository(this.preferences); final SharedPreferences preferences; static const key = 'profile.v1';
  Future<void> save(UserProfile p) => preferences.setString(key, jsonEncode({'height':p.heightCm,'weight':p.weightKg,'age':p.age,'sex':p.sex.name,'activity':p.activityFactor,'loss':p.targetLossKgPerWeek}));
  UserProfile? load() { final raw=preferences.getString(key); if(raw==null)return null; try { final m=jsonDecode(raw) as Map; return UserProfile(heightCm:(m['height'] as num).toDouble(),weightKg:(m['weight'] as num).toDouble(),age:(m['age'] as num).toInt(),sex:BiologicalSex.values.firstWhere((x)=>x.name==m['sex'],orElse:()=>BiologicalSex.unspecified),activityFactor:(m['activity'] as num).toDouble(),targetLossKgPerWeek:(m['loss'] as num).toDouble()); } catch (_) { return null; } }
}
