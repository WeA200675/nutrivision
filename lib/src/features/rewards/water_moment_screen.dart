import 'package:flutter/material.dart';

class WaterMomentScreen extends StatefulWidget {
  const WaterMomentScreen({super.key});
  @override State<WaterMomentScreen> createState() => _WaterMomentScreenState();
}

class _WaterMomentScreenState extends State<WaterMomentScreen> with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..forward();
  @override void dispose() { controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFDDF4FF),
    body: AnimatedBuilder(animation: controller, builder: (context, _) {
      final t = controller.value;
      return Stack(alignment: Alignment.center, children: [
        Positioned.fill(child: CustomPaint(painter: _PondPainter(t))),
        Transform.translate(offset: Offset(-180 + 360 * t, 20), child: const Text('🐢', style: TextStyle(fontSize: 72))),
        Positioned(left: 100 + 180 * t, top: 300, child: Opacity(opacity: (t * 2).clamp(0.0, 1.0), child: const Text('🐟', style: TextStyle(fontSize: 34)))),
        Positioned(right: 100 + 160 * (1 - t), top: 390, child: Opacity(opacity: ((t - .2) * 2).clamp(0.0, 1.0), child: const Text('🐟', style: TextStyle(fontSize: 30)))),
        Positioned(bottom: 120, child: Opacity(opacity: t, child: const Text('+1 Teichwachstum', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF175B73))))),
        Positioned(top: 70, right: 20, child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Überspringen'))),
      ]);
    }),
  );
}

class _PondPainter extends CustomPainter {
  _PondPainter(this.progress);
  final double progress;
  @override void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF62C7E8).withValues(alpha: .65);
    final height = 180 + 100 * progress;
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width / 2, size.height / 2 + 80), width: size.width * .82, height: height), paint);
  }
  @override bool shouldRepaint(covariant _PondPainter oldDelegate) => oldDelegate.progress != progress;
}

