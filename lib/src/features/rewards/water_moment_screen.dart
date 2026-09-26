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
        Transform.translate(offset: Offset(-110 + 220 * t, 20), child: Container(width: 190, height: 190, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .7)), alignment: Alignment.center, child: const Text('🐢', style: TextStyle(fontSize: 116)))),
        Positioned(left: 110 + 120 * t, top: 310, child: Opacity(opacity: (t * 2).clamp(0.0, 1.0), child: const Text('🐟', style: TextStyle(fontSize: 52)))),
        Positioned(right: 110 + 100 * (1 - t), top: 410, child: Opacity(opacity: ((t - .2) * 2).clamp(0.0, 1.0), child: const Text('🐟', style: TextStyle(fontSize: 46)))),
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

