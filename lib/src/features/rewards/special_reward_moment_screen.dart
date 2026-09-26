import 'dart:math';
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
  late final String companion = _randomCompanion(widget.animal);
  late final bool companionFromLeft = Random().nextBool();
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
        backgroundColor: _sceneColor(widget.animation),
        body: SafeArea(child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = Curves.easeOutBack.transform(_controller.value);
            return Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(child: CustomPaint(painter: _BurstPainter(_controller.value, widget.animation))),
                Transform.translate(
                  offset: Offset(0, -18 * (1 - t) + 5 * sin(_controller.value * 6.28)),
                  child: Transform.rotate(
                    angle: .045 * sin(_controller.value * 6.28),
                    child: Transform.scale(
                      scale: .72 + .28 * t,
                      child: Container(
                        width: MediaQuery.sizeOf(context).shortestSide * .62,
                        height: MediaQuery.sizeOf(context).shortestSide * .62,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .88), boxShadow: const [BoxShadow(color: Color(0x446A4300), blurRadius: 24, spreadRadius: 4)]),
                        alignment: Alignment.center,
                        child: Text(_animalEmoji(widget.animal), style: TextStyle(fontSize: MediaQuery.sizeOf(context).shortestSide * .45)),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: companionFromLeft ? 28 + 150 * Curves.easeOut.transform(_controller.value) : null,
                  right: companionFromLeft ? null : 28 + 150 * Curves.easeOut.transform(_controller.value),
                  bottom: 210,
                  child: Opacity(
                    opacity: ((_controller.value - .3) * 1.5).clamp(0.0, 1.0),
                    child: Transform.rotate(
                      angle: -.08,
                      child: Text(companion, style: const TextStyle(fontSize: 72)),
                    ),
                  ),
                ),
                Positioned(
                  top: 150,
                  child: Opacity(
                    opacity: _controller.value.clamp(0, 1),
                    child: Text(
                      '${widget.animation} · Dreifach stark!',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF6A4300)),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 190,
                  child: Opacity(
                    opacity: ((_controller.value - .25) * 1.4).clamp(0, 1),
                    child: Text(
                      '${widget.animal} feuert dich an: ${_message(widget.animation)}',
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
        )),
      );
}

String _animalEmoji(String animal) => switch (animal) {
      'Giraffe' => '🦒', 'Tiger' => '🐅', 'Kuh' => '🐄', 'Wasserschildkröte' => '🐢', _ => '🐘'
    };

Color _sceneColor(String animation) => switch (animation) {
      'Lichtwelle' => const Color(0xFFE0F6FF),
      'Farbwirbel' => const Color(0xFFF3E4FF),
      'Konfetti-Sprung' => const Color(0xFFFFE8EF),
      'Goldener Funke' => const Color(0xFFFFF4D8),
      'Kometenlauf' => const Color(0xFFE8EEFF),
      _ => const Color(0xFFFFF4D8),
    };

String _message(String animation) => switch (animation) {
      'Lichtwelle' => 'Dein Fortschritt zieht Kreise.',
      'Farbwirbel' => 'Du bringst richtig Bewegung hinein.',
      'Konfetti-Sprung' => 'Diesen Erfolg darfst du feiern.',
      'Goldener Funke' => 'Kleine Schritte, starke Wirkung.',
      'Kometenlauf' => 'Du bleibst auf deinem Weg.',
      _ => 'Deine NutriWorld wächst weiter.',
    };

String _randomCompanion(String animal) {
  final options = switch (animal) {
    'Wasserschildkröte' => ['🐟', '🐠'],
    'Tiger' => ['🦒', '🐘'],
    'Giraffe' => ['🐘', '🐄'],
    'Kuh' => ['🐅', '🦒'],
    _ => ['🦒', '🐄'],
  };
  return options[Random().nextInt(options.length)];
}

class _BurstPainter extends CustomPainter {
  const _BurstPainter(this.progress, this.animation);
  final double progress;
  final String animation;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..strokeWidth = 4..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    for (var i = 0; i < 18; i++) {
      final angle = i * 3.14159 * 2 / 18;
      final radius = 80 + 300 * progress;
      paint.color = Colors.primaries[i % Colors.primaries.length].withValues(alpha: (1 - progress).clamp(.15, .85));
      if (animation == 'Lichtwelle') {
        canvas.drawCircle(center, 90 + i * 14 * progress, paint);
      } else if (animation == 'Farbwirbel') {
        canvas.drawArc(Rect.fromCircle(center: center, radius: radius * .65), angle, 1.2, false, paint);
      } else if (animation == 'Konfetti-Sprung') {
        final dot = center + Offset.fromDirection(angle, radius * .7);
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(dot, 5 + (i % 3) * 2, paint);
        paint.style = PaintingStyle.stroke;
      } else {
        canvas.drawLine(center + Offset.fromDirection(angle, 48), center + Offset.fromDirection(angle, radius), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter oldDelegate) => oldDelegate.progress != progress || oldDelegate.animation != animation;
}

