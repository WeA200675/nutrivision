import 'package:flutter/material.dart';
import 'nutri_world.dart';
import 'nutri_world_seasonal_overlay.dart';
import 'world_memory.dart';

class NutriWorldScreen extends StatefulWidget {
  const NutriWorldScreen({super.key, required this.repository});
  final NutriWorldRepository repository;
  @override State<NutriWorldScreen> createState() => _NutriWorldScreenState();
}

class _NutriWorldScreenState extends State<NutriWorldScreen> {
  late NutriWorldState state;
  late String message;

  @override
  void initState() {
    super.initState();
    state = widget.repository.load();
    message = WorldMemoryRepository(widget.repository.preferences).messageFor(state);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Meine NutriWorld')),
    body: LayoutBuilder(
      builder: (context, box) => ClipRect(child: Stack(
        fit: StackFit.expand,
        children: [
          InteractiveViewer(
            minScale: .65,
            maxScale: 4,
            boundaryMargin: const EdgeInsets.all(180),
            constrained: false,
            child: SizedBox(
              width: 1600,
              height: 1067,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/world/nutriworld_base.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFFBFE8F2)),
                  ),
                  NutriWorldSeasonalOverlay(state: state),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 18,
            child: Card(
              color: Colors.white.withValues(alpha: .9),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(message, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      )),
    ),
  );
}
