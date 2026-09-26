import 'package:flutter/material.dart';

class MealMomentScreen extends StatefulWidget {
  const MealMomentScreen({super.key, required this.mealName});
  final String mealName;
  @override State<MealMomentScreen> createState() => _MealMomentScreenState();
}

class _MealMomentScreenState extends State<MealMomentScreen> with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1700))..forward();
  @override void dispose() { controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(backgroundColor: const Color(0xFFFFF0D6), body: SafeArea(child: AnimatedBuilder(animation: controller, builder: (context, _) {
    final t = Curves.easeOutBack.transform(controller.value);
    return Stack(alignment: Alignment.center, children: [
      Positioned.fill(child: CustomPaint(painter: _PlatePainter(controller.value))),
      Transform.scale(scale: .72 + .28 * t, child: const Text('🥗', style: TextStyle(fontSize: 150))),
      Positioned(top: 145, child: Opacity(opacity: controller.value, child: const Text('Gute Wahl!', style: TextStyle(fontSize: 31, fontWeight: FontWeight.w800, color: Color(0xFF704A18))))),
      Positioned(bottom: 165, child: Opacity(opacity: controller.value, child: SizedBox(width: 320, child: Text('„${widget.mealName}“ ist eingetragen.', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: Color(0xFF704A18))))),
      Positioned(bottom: 65, child: FilledButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.check_circle), label: const Text('Weiter'))),
      Positioned(top: 36, right: 12, child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Überspringen'))),
    ]);
  })));
}

class _PlatePainter extends CustomPainter {
  _PlatePainter(this.progress);
  final double progress;
  @override void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 5..color = const Color(0xFFE5A63B).withValues(alpha: .75);
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, 120 + 30 * progress, paint);
    canvas.drawCircle(center, 145 + 30 * progress, paint..color = const Color(0xFFE5A63B).withValues(alpha: .25));
  }
  @override bool shouldRepaint(covariant _PlatePainter oldDelegate) => oldDelegate.progress != progress;
}

