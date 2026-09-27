import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'activity_repository.dart';
import '../rewards/nutri_world.dart';
import '../rewards/reward_events.dart';
import '../rewards/special_reward_moment_screen.dart';
import '../rewards/activity_moment_screen.dart';
import 'exercise_planner.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key, required this.repository});
  final ActivityRepository repository;
  @override State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late List<ActivityTask> tasks;
  bool _plansShown = false;
  @override void initState() { super.initState(); tasks = widget.repository.load(); }

  Future<void> _reward() async {
    final prefs = await SharedPreferences.getInstance();
    final result = await RewardService(NutriWorldRepository(prefs)).record(RewardEvent.activityCompleted);
    if (mounted) {
      final minutes = tasks.where((task) => task.done).fold<int>(0, (sum, task) => sum + task.minutes);
      await Navigator.push(context, MaterialPageRoute(builder: (_) => ActivityMomentScreen(minutes: minutes)));
    }
    if (result.specialMoment && mounted) {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => SpecialRewardMomentScreen(successes: result.successes, animation: result.animation, animal: result.animal)));
    }
  }

  Future<void> add() async {
    final title = TextEditingController();
    final mins = TextEditingController(text: '15');
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('Aktivität hinzufügen'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, decoration: const InputDecoration(labelText: 'Aktivität')),
        TextField(controller: mins, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Dauer (Minuten)')),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hinzufügen'))],
    ));
    final m = int.tryParse(mins.text);
    if (ok == true && title.text.trim().isNotEmpty && m != null && m > 0) {
      setState(() => tasks = [...tasks, ActivityTask(id: DateTime.now().microsecondsSinceEpoch.toString(), title: title.text.trim(), minutes: m)]);
      await widget.repository.save(tasks);
    }
  }

  Future<void> toggle(int i) async {
    final wasDone = tasks[i].done;
    final copy = [...tasks]; copy[i] = copy[i].copyWith(done: !wasDone);
    setState(() => tasks = copy); await widget.repository.save(tasks);
    if (!wasDone) {
      final prefs = await SharedPreferences.getInstance();
      final planner = ExercisePlanner(prefs);
      final result = await planner.record(tasks[i].title);
      if (result.plansReady && !_plansShown && mounted) {
        final plans = planner.loadPlans();
        if (plans.isNotEmpty) {
          _plansShown = true;
          await _showPlans(plans, title: 'Deine neue Tierplanung');
        }
      }
      await _reward();
    }
  }

  Future<void> _showPlans(List<ExercisePlan> plans, {String title = 'Tierplanung'}) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(children: [
          const Icon(Icons.auto_awesome, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
        ]),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: plans.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final plan = plans[i];
              return ListTile(
                leading: Text(_animalEmoji(plan.animal), style: const TextStyle(fontSize: 30)),
                title: Text('${plan.animal}: ${plan.exercise}'),
                subtitle: Text(plan.reason),
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Schließen'))],
      ),
    );
  }

  String _animalEmoji(String animal) => switch (animal) {
    'Elefantin' => '🐘',
    'Tiger' => '🐅',
    'Giraffe' => '🦒',
    'Kuh' => '🐄',
    _ => '🐢',
  };

  @override Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(
      title: const Text('Aktivitäten'),
      actions: [
        FutureBuilder<SharedPreferences>(
          future: SharedPreferences.getInstance(),
          builder: (_, snapshot) {
            final plans = snapshot.hasData ? ExercisePlanner(snapshot.data!).loadPlans() : const <ExercisePlan>[];
            if (plans.isEmpty) return const SizedBox.shrink();
            return IconButton(tooltip: 'Tierplanung anzeigen', icon: const Icon(Icons.auto_awesome), onPressed: () => _showPlans(plans));
          },
        ),
      ],
    ),
    body: ListView(children: [for (var i = 0; i < tasks.length; i++) CheckboxListTile(value: tasks[i].done, onChanged: (_) => toggle(i), title: Text(tasks[i].title), subtitle: Text('${tasks[i].minutes} Minuten'))]),
    floatingActionButton: FloatingActionButton.extended(onPressed: add, icon: const Icon(Icons.add), label: const Text('Aktivität')),
  );
}
