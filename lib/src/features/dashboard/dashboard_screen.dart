import 'package:flutter/material.dart';
import '../diary/diary_screen.dart';
import '../nutrition/nutrition_catalog.dart';
import '../diary/meal_repository.dart';
import '../profile/profile_screen.dart';
import '../profile/profile_repository.dart';
import '../profile/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.repository, required this.catalog});
  final MealRepository repository;
  final NutritionCatalog catalog;
  @override State<DashboardScreen> createState() => _DashboardScreenState();
}
class _DashboardScreenState extends State<DashboardScreen> {
  int water = 0;
  UserProfile? profile;
  @override void initState(){super.initState(); _loadProfile();}
  Future<void> _loadProfile() async { final prefs=await SharedPreferences.getInstance(); final loaded=ProfileRepository(prefs).load(); if(mounted)setState(()=>profile=loaded); }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('🌻 NutriVision')),
    body: GridView.count(crossAxisCount: 2, padding: const EdgeInsets.all(16), crossAxisSpacing: 12, mainAxisSpacing: 12, children: [
      _tile(context, 'Heute', profile == null ? 'Profil einrichten' : '0 / ${profile!.safeDailyCalories.round()} kcal', Icons.local_fire_department, const Color(0xFFFFE0B2), () => Navigator.push(context, MaterialPageRoute(builder: (_) => DiaryScreen(repository: widget.repository, catalog: widget.catalog)))),
      _tile(context, 'Mein Profil', profile == null ? 'Noch nicht eingerichtet' : 'BMI ${profile!.bmi.toStringAsFixed(1)}', Icons.person, const Color(0xFFD7E8FF), () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(initial: profile, onSaved: (saved) => setState(() => profile = saved))))),
      _tile(context, 'Wasser', '${water / 1000} / 2,0 l', Icons.water_drop, const Color(0xFFCDEBFF), () => setState(() => water += 250)),
      _tile(context, 'Bewegung', 'Aufgabe des Tages', Icons.directions_walk, const Color(0xFFFFD6E7), () {}),
      _tile(context, 'Lebensmittel', 'Suche und Barcode', Icons.qr_code_scanner, const Color(0xFFE4D8FF), () => Navigator.push(context, MaterialPageRoute(builder: (_) => DiaryScreen(repository: widget.repository, catalog: widget.catalog)))),
      _tile(context, 'Statistik', 'Dein Fortschritt', Icons.show_chart, const Color(0xFFD7F2D1), () {}),
    ]),
  );
  Widget _tile(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) => Card(color: color, clipBehavior: Clip.antiAlias, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Stack(children: [Positioned(right: -18, top: -18, child: Icon(icon, size: 112, color: Colors.white.withValues(alpha: 0.42))), Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary), const Spacer(), Text(title, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 4), Text(subtitle)]))])));
}
