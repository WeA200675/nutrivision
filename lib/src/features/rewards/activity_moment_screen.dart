import 'dart:math';
import 'package:flutter/material.dart';

class ActivityMomentScreen extends StatefulWidget {
  const ActivityMomentScreen({super.key, required this.minutes});
  final int minutes;
  @override State<ActivityMomentScreen> createState() => _ActivityMomentScreenState();
}

class _ActivityMomentScreenState extends State<ActivityMomentScreen> with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();
  @override void dispose() { controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(backgroundColor: const Color(0xFFFFE8F0), body: SafeArea(child: LayoutBuilder(builder: (context, constraints) => AnimatedBuilder(animation: controller, builder: (context, _) {
    final t = controller.value;
    final x = -100 + (constraints.maxWidth + 200) * t;
    final bounce = sin(t * 3.14159 * 8).abs() * 10;
    return Stack(alignment: Alignment.center, children: [
      Positioned.fill(child: CustomPaint(painter: _TrackPainter(t))),
      Positioned(left: x, top: constraints.maxHeight * .38 - bounce, child: Transform.scale(scale: 1 + sin(t * 3.14159 * 8).abs() * .04, child: const Text('🐅', style: TextStyle(fontSize: 122)))),
      Positioned(top: 150, child: Opacity(opacity: t, child: const Text('Stark bewegt!', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Color(0xFF7A2344))))),
      Positioned(bottom: 160, child: Opacity(opacity: t, child: Text('${widget.minutes} Minuten geschafft – genau so weiter.', style: const TextStyle(fontSize: 17, color: Color(0xFF7A2344))))),
      Positioned(bottom: 65, child: FilledButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.directions_run), label: const Text('Weiter'))),
      Positioned(top: 36, right: 12, child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Überspringen'))),
    ]);
  }))));
}

class _TrackPainter extends CustomPainter {
  _TrackPainter(this.progress);
  final double progress;
  @override void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFF39AB8).withValues(alpha: .4)..strokeWidth = 7..strokeCap = StrokeCap.round;
    final y = size.height * .56;
    for (var i = 0; i < 8; i++) canvas.drawLine(Offset(24 + i * 70 - progress * 70, y), Offset(54 + i * 70 - progress * 70, y), paint);
  }
  @override bool shouldRepaint(covariant _TrackPainter oldDelegate) => oldDelegate.progress != progress;
}

