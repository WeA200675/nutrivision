import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'activity_repository.dart';
import '../rewards/nutri_world.dart';
import '../rewards/reward_events.dart';
import '../rewards/special_reward_moment_screen.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key, required this.repository});
  final ActivityRepository repository;
  @override State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late List<ActivityTask> tasks;
  @override void initState() { super.initState(); tasks = widget.repository.load(); }

  Future<void> _reward() async {
    final prefs = await SharedPreferences.getInstance();
    final result = await RewardService(NutriWorldRepository(prefs)).record(RewardEvent.activityCompleted);
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
    if (!wasDone) await _reward();
  }

  @override Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('Aktivitäten')),
    body: ListView(children: [for (var i = 0; i < tasks.length; i++) CheckboxListTile(value: tasks[i].done, onChanged: (_) => toggle(i), title: Text(tasks[i].title), subtitle: Text('${tasks[i].minutes} Minuten'))]),
    floatingActionButton: FloatingActionButton.extended(onPressed: add, icon: const Icon(Icons.add), label: const Text('Aktivität')),
  );
}

