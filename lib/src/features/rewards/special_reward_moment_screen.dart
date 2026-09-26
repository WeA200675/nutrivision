import 'package:flutter/material.dart';

class SpecialRewardMomentScreen extends StatefulWidget {
  const SpecialRewardMomentScreen({super.key, required this.successes, required this.animation, required this.animal});
  final int successes;
  final String animation;
  final String animal;

  @override
  State<SpecialRewardMomentScreen> createState() => _SpecialRewardMomentScreenState();
}

class _SpecialRewardMomentScreenState extends State<SpecialRewardMomentScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFFFF4D8),
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = Curves.easeOutBack.transform(_controller.value);
            return Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(child: CustomPaint(painter: _BurstPainter(_controller.value))),
                Transform.scale(
                  scale: .72 + .28 * t,
                  child: Text(_animalEmoji(widget.animal), style: const TextStyle(fontSize: 112)),
                ),
                Positioned(
                  top: 150,
                  child: Opacity(
                    opacity: _controller.value.clamp(0, 1),
                    child: Text(
                      '${widget.animation} · Dreifach stark!',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF6A4300)),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 190,
                  child: Opacity(
                    opacity: ((_controller.value - .25) * 1.4).clamp(0, 1),
                    child: Text(
                      '${widget.animal} feuert dich an: Deine NutriWorld wächst weiter!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, color: Color(0xFF6A4300)),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 70,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.rocket_launch),
                    label: const Text('Weiter so'),
                  ),
                ),
                Positioned(
                  top: 55,
                  right: 16,
                  child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Überspringen')),
                ),
              ],
            );
          },
        ),
      );
}

String _animalEmoji(String animal) => switch (animal) {
      'Giraffe' => '🦒', 'Tiger' => '🐅', 'Kuh' => '🐄', 'Wasserschildkröte' => '🐢', _ => '🐘'
    };

class _BurstPainter extends CustomPainter {
  const _BurstPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..strokeWidth = 4..strokeCap = StrokeCap.round;
    for (var i = 0; i < 18; i++) {
      final angle = i * 3.14159 * 2 / 18;
      final radius = 60 + 260 * progress;
      paint.color = Colors.primaries[i % Colors.primaries.length].withValues(alpha: (1 - progress).clamp(.15, .85));
      canvas.drawLine(center + Offset.fromDirection(angle, 48), center + Offset.fromDirection(angle, radius), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter oldDelegate) => oldDelegate.progress != progress;
}

