import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WorldMemory { const WorldMemory({required this.title,required this.message,required this.createdAt}); final String title,message; final DateTime createdAt; Map<String,String> toJson()=>{'title':title,'message':message,'createdAt':createdAt.toIso8601String()}; factory WorldMemory.fromJson(Map v)=>WorldMemory(title:v['title'] as String? ??'',message:v['message'] as String? ??'',createdAt:DateTime.tryParse(v['createdAt'] as String? ??'')??DateTime.now()); }
class WorldMemoryRepository {
  WorldMemoryRepository(this.preferences); final SharedPreferences preferences; static const key='nutri-world.memories.v1';
  List<WorldMemory> load(){final raw=preferences.getString(key);if(raw==null)return const [];try{return (jsonDecode(raw) as List).whereType<Map>().map(WorldMemory.fromJson).toList();}catch(_){return const [];}}
  Future<void> add(String title,String message)async{final memories=[...load(),WorldMemory(title:title,message:message,createdAt:DateTime.now())];await preferences.setString(key,jsonEncode(memories.map((m)=>m.toJson()).toList()));}
  String messageFor(NutriWorldState state){final memories=load();if(memories.isNotEmpty)return memories.last.message;final total=state.garden+state.tree+state.path+state.pond+state.kitchen+state.pantry;return total==0?'Deine Welt wartet auf ihren ersten schönen Moment.':total<5?'Jeder kleine Schritt lässt NutriWorld weiter aufblühen.':'Deine NutriWorld wächst, weil du gut auf dich achtest.';}
}
