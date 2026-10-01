import 'package:flutter/material.dart';

class AnimalMascot extends StatelessWidget {
  const AnimalMascot({super.key, required this.animal, this.stride = 0});
  final String animal;
  final double stride;
  @override Widget build(BuildContext context) => CustomPaint(size: const Size(64, 64), painter: _MascotPainter(animal, stride));
}

class _MascotPainter extends CustomPainter {
  _MascotPainter(this.animal, this.stride);
  final String animal;
  final double stride;
  @override void paint(Canvas canvas, Size size) {
    final s = size.shortestSide / 64;
    canvas.scale(s);
    final fill = Paint()..style = PaintingStyle.fill;
    final stroke = Paint()..style = PaintingStyle.stroke..strokeWidth = 2.2..color = const Color(0xFF183D35);
    Color body = switch (animal) { 'Elefantin' => const Color(0xFFB5C8D8), 'Tiger' => const Color(0xFFFFA94D), 'Giraffe' => const Color(0xFFFFD76A), 'Kuh' => const Color(0xFFF7F1E5), _ => const Color(0xFF62C5B3) };
    fill.color = body;
    canvas.drawOval(const Rect.fromLTWH(13, 25, 39, 28), fill);
    canvas.drawCircle(const Offset(43, 24), 14, fill);
    canvas.drawOval(const Rect.fromLTWH(32, 10, 9, 13), fill);
    canvas.drawOval(const Rect.fromLTWH(47, 10, 9, 13), fill);
    if (animal == 'Elefantin') { canvas.drawOval(const Rect.fromLTWH(51, 25, 13, 7), fill); }
    if (animal == 'Tiger') { stroke.color = const Color(0xFF6D3A16); for (var i = 0; i < 3; i++) canvas.drawLine(Offset(35 + i * 6, 15), Offset(32 + i * 7, 27), stroke); }
    if (animal == 'Giraffe') { stroke.color = const Color(0xFFB17728); for (var i = 0; i < 3; i++) canvas.drawCircle(Offset(17 + i * 10, 34 + (i % 2) * 8), 3, stroke); }
    if (animal == 'Kuh') { fill.color = const Color(0xFF403D47); canvas.drawOval(const Rect.fromLTWH(37, 16, 8, 6), fill); canvas.drawOval(const Rect.fromLTWH(49, 28, 7, 5), fill); }
    fill.color = const Color(0xFF183D35); canvas.drawCircle(const Offset(47, 21), 2, fill); canvas.drawCircle(const Offset(54, 21), 2, fill);
    final leg = stride * 5;
    canvas.drawLine(Offset(23, 51), Offset(21 + leg, 61), stroke); canvas.drawLine(Offset(40, 51), Offset(42 - leg, 61), stroke);
  }
  @override bool shouldRepaint(covariant _MascotPainter oldDelegate) => oldDelegate.animal != animal;
}
