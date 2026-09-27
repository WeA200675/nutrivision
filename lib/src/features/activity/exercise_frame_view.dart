import 'package:flutter/material.dart';
import 'exercise_frames.dart';
import 'animal_mascot.dart';

class ExerciseFrameView extends StatefulWidget {
  const ExerciseFrameView({super.key, required this.frames, required this.emoji, required this.animal});
  final List<ExerciseFrame> frames;
  final String emoji;
  final String animal;
  @override State<ExerciseFrameView> createState() => _ExerciseFrameViewState();
}

class _ExerciseFrameViewState extends State<ExerciseFrameView> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override void initState() { super.initState(); _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(); }
  @override void dispose() { _controller.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    if (widget.frames.isEmpty) return AnimalMascot(animal: widget.animal);
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final index = (_controller.value * widget.frames.length).floor().clamp(0, widget.frames.length - 1);
        final frame = widget.frames[index];
        return Transform.translate(
          offset: Offset((frame.x - .5) * 90, (frame.y - .5) * 12),
          child: Transform.rotate(angle: frame.rotation, child: Transform.scale(scale: frame.scale, child: AnimalMascot(animal: widget.animal, stride: frame.stride))),
        );
      },
    );
  }
}
