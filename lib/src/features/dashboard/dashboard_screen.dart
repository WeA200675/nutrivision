import 'package:flutter/material.dart';
import '../diary/diary_screen.dart';
import '../nutrition/nutrition_catalog.dart';
import '../diary/meal_repository.dart';
import '../profile/profile_screen.dart';
import '../profile/profile_repository.dart';
import '../profile/user_profile.dart';
import '../activity/activity_screen.dart';
import '../activity/activity_repository.dart';
import '../stats/statistics_screen.dart';
import '../rewards/nutri_world.dart';
import '../rewards/nutri_world_screen.dart';
import '../rewards/reward_events.dart';
import '../rewards/water_moment_screen.dart';
import '../rewards/special_reward_moment_screen.dart';
import '../hydration/water_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.repository, required this.catalog});
  final MealRepository repository;
  final NutritionCatalog catalog;
  @override State<DashboardScreen> createState() => _DashboardScreenState();
}
class _DashboardScreenState extends State<DashboardScreen> {
  int water = 0;
  bool _addingWater = false;
  UserProfile? profile;
  int get _waterGoalMl {
    final weight = profile?.weightKg;
    if (weight == null || weight <= 0) return 2000;
    return (weight * 30).round().clamp(1500, 3500);
  }
  @override void initState(){super.initState(); _loadProfile();}
  Future<void> _loadProfile() async { final prefs=await SharedPreferences.getInstance(); final loaded=ProfileRepository(prefs).load(); final todayWater=WaterRepository(prefs).load(DateTime.now()); if(mounted)setState(() { profile=loaded; water=todayWater; }); }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('🌻 NutriVision')),
    body: GridView.count(crossAxisCount: 2, padding: const EdgeInsets.all(16), crossAxisSpacing: 12, mainAxisSpacing: 12, children: [
      _tile(context, 'Heute', profile == null ? 'Profil einrichten' : '0 / ${profile!.safeDailyCalories.round()} kcal', Icons.local_fire_department, const Color(0xFFFFE0B2), () => Navigator.push(context, MaterialPageRoute(builder: (_) => DiaryScreen(repository: widget.repository, catalog: widget.catalog)))),
      _tile(context, 'Mein Profil', profile == null ? 'Noch nicht eingerichtet' : 'BMI ${profile!.bmi.toStringAsFixed(1)}', Icons.person, const Color(0xFFD7E8FF), () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(initial: profile, onSaved: (saved) { setState(() => profile = saved); SharedPreferences.getInstance().then((prefs) => ProfileRepository(prefs).save(saved)); })))),
      _tile(context, 'Wasser', '${(water / 1000).toStringAsFixed(2)} / ${(_waterGoalMl / 1000).toStringAsFixed(1)} l', Icons.water_drop, const Color(0xFFCDEBFF), _addingWater ? () {} : _addWater),
      _tile(context, 'Bewegung', 'Aufgabe des Tages', Icons.directions_walk, const Color(0xFFFFD6E7), () async { final prefs = await SharedPreferences.getInstance(); if (!context.mounted) return; Navigator.push(context, MaterialPageRoute(builder: (_) => ActivityScreen(repository: ActivityRepository(prefs)))); }),
      _tile(context, 'Lebensmittel', 'Suche und Barcode', Icons.qr_code_scanner, const Color(0xFFE4D8FF), () => Navigator.push(context, MaterialPageRoute(builder: (_) => DiaryScreen(repository: widget.repository, catalog: widget.catalog)))),
      _tile(context, 'Statistik', 'Dein Fortschritt', Icons.show_chart, const Color(0xFFD7F2D1), () => Navigator.push(context, MaterialPageRoute(builder: (_) => StatisticsScreen(repository: widget.repository)))), _tile(context, 'NutriWorld', 'Deine Welt wächst', Icons.public, const Color(0xFFFFE6A8), () async { final prefs = await SharedPreferences.getInstance(); if (!context.mounted) return; Navigator.push(context, MaterialPageRoute(builder: (_) => NutriWorldScreen(repository: NutriWorldRepository(prefs)))); }),
    ]),
  );
  Future<void> _addWater() async {
    if (_addingWater) return;
    setState(() => _addingWater = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final before = WaterRepository(prefs).load(DateTime.now());
      await WaterRepository(prefs).add(DateTime.now(), milliliters: 250);
      if (!mounted) return;
      final after = WaterRepository(prefs).load(DateTime.now());
      setState(() => water = after);
      final rewards = RewardService(NutriWorldRepository(prefs));
      final result = await rewards.record(RewardEvent.waterLogged);
      if (!mounted) return;
      await Navigator.push(context, MaterialPageRoute(builder: (_) => const WaterMomentScreen()));
      if (result.specialMoment && mounted) {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => SpecialRewardMomentScreen(successes: result.successes, animation: result.animation, animal: result.animal)));
      }
      if (before < _waterGoalMl && after >= _waterGoalMl && mounted) {
        await rewards.record(RewardEvent.calorieGoalReached);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trinkziel erreicht – deine NutriWorld erhält einen Bonus!')));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wasser konnte nicht gespeichert werden.')));
    } finally {
      if (mounted) setState(() => _addingWater = false);
    }
  }
  Widget _tile(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.0, end: 1.0), duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic,
    builder: (context, value, child) => Opacity(opacity: value, child: Transform.translate(offset: Offset(0, 18 * (1 - value)), child: child)),
    child: Card(color: color, clipBehavior: Clip.antiAlias, child: InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(12), child: Stack(children: [
        Positioned(right: 8, top: 18, child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0), duration: const Duration(seconds: 3), curve: Curves.easeInOut,
          builder: (context, v, _) => Transform.translate(offset: Offset(-4 * v, 4 * v), child: Icon(icon, size: 176, color: Colors.white.withValues(alpha: 0.42))),
        )),
        Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary), const Spacer(),
          Text(title, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 4), Text(subtitle),
        ])),
      ]),
    )),
  );
}

