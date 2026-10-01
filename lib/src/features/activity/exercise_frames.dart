import 'dart:convert';
import 'dart:math';

/// Reusable, device-independent animation data. The renderer decides how to draw it.
class ExerciseFrame {
  const ExerciseFrame({required this.x, required this.y, required this.scale, required this.rotation, required this.stride});
  final double x;
  final double y;
  final double scale;
  final double rotation;
  final double stride;

  Map<String, double> toJson() => {'x': x, 'y': y, 'scale': scale, 'rotation': rotation, 'stride': stride};
  factory ExerciseFrame.fromJson(Map value) => ExerciseFrame(
    x: (value['x'] as num?)?.toDouble() ?? 0,
    y: (value['y'] as num?)?.toDouble() ?? 0,
    scale: (value['scale'] as num?)?.toDouble() ?? 1,
    rotation: (value['rotation'] as num?)?.toDouble() ?? 0,
    stride: (value['stride'] as num?)?.toDouble() ?? 0,
  );
}

class ExerciseFrameGenerator {
  const ExerciseFrameGenerator();
  static const frameCount = 30;

  List<ExerciseFrame> generate({required String animal, required String exercise}) {
    final seed = animal.codeUnits.fold<int>(0, (a, b) => a + b) + exercise.codeUnits.fold<int>(0, (a, b) => a + b);
    final phase = (seed % 17) / 17 * pi;
    return [for (var i = 0; i < frameCount; i++) _frame(i, phase, exercise)];
  }

  ExerciseFrame _frame(int index, double phase, String exercise) {
    final t = index / frameCount * 2 * pi + phase;
    final pulse = sin(t);
    final sway = cos(t);
    final squat = exercise == 'Kniebeugen' || exercise == 'Wandsitzen' ? pulse.abs() : pulse * .35;
    final side = exercise == 'Seitbeugen' ? pulse * .16 : sway * .04;
    final walkingX = .2 + (index / (frameCount - 1)) * .6;
    return ExerciseFrame(x: walkingX, y: .56 + squat * .08 + side, scale: 1 + squat * .06, rotation: side, stride: sin(t));
  }

  static String encode(List<ExerciseFrame> frames) => jsonEncode(frames.map((frame) => frame.toJson()).toList());
  static List<ExerciseFrame> decode(String raw) {
    try { return (jsonDecode(raw) as List).whereType<Map>().map(ExerciseFrame.fromJson).toList(); } catch (_) { return const []; }
  }
}
