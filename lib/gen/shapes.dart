import 'dart:math';
import 'dart:ui' show Color;
import '../models.dart';
import 'util.dart';

const List<String> _shadowObjects = [
  '🐘', '🦒', '🦋', '🌲', '🚀', '⛵', '🍎', '🐟', '🦉', '🐢', '🌻', '🚁',
];

const List<String> _shapeSymbols = ['●', '■', '▲', '★', '◆'];

const List<Color> _tileColors = [
  Color(0xFFE53935),
  Color(0xFF1E88E5),
  Color(0xFF43A047),
  Color(0xFFFDD835),
  Color(0xFF8E24AA),
  Color(0xFFFB8C00),
];

Puzzle buildShadow(Random rnd) {
  final answer = pick(rnd, _shadowObjects);
  final others = shuffled(rnd, _shadowObjects.where((e) => e != answer).toList()).take(2).toList();
  final options = [...others, answer]..shuffle(rnd);
  return ShadowPuzzle(
    prompt: '这是谁的影子呀？',
    silhouetteEmoji: answer,
    options: [for (final e in options) OptionSpec(emoji: e)],
    correct: options.indexOf(answer),
  );
}

int _findOption(List<OptionSpec> options, String shape, Color color) {
  for (var i = 0; i < options.length; i++) {
    if (options[i].shape == shape && options[i].color == color) return i;
  }
  return -1;
}

Puzzle buildTile(Random rnd) {
  final shapes = shuffled(rnd, _shapeSymbols).take(3).toList();
  final colors = shuffled(rnd, _tileColors).take(3).toList();
  final tiles = <OptionSpec>[];
  for (var row = 0; row < 3; row++) {
    for (var col = 0; col < 3; col++) {
      tiles.add(OptionSpec(shape: shapes[col], color: colors[row]));
    }
  }
  final blank = ri(rnd, 0, 8);
  final correctShape = shapes[blank % 3];
  final correctColor = colors[blank ~/ 3];

  final options = <OptionSpec>[
    OptionSpec(shape: correctShape, color: correctColor),
  ];
  final wrongColors = _tileColors.where((c) => c != correctColor).toList()..shuffle(rnd);
  final wrongShapes = _shapeSymbols.where((s) => s != correctShape).toList()..shuffle(rnd);
  options.add(OptionSpec(shape: correctShape, color: wrongColors[0]));
  options.add(OptionSpec(shape: wrongShapes[0], color: correctColor));
  options.add(OptionSpec(
    shape: wrongShapes[1],
    color: wrongColors[1 % wrongColors.length],
  ));
  final mixed = options..shuffle(rnd);
  final correct = _findOption(mixed, correctShape, correctColor);
  return TilePuzzle(
    prompt: '拼图缺了哪一块呀？',
    cols: 3,
    rows: 3,
    tiles: tiles,
    blankIndex: blank,
    options: mixed,
    correct: correct < 0 ? 0 : correct,
  );
}

List<Puzzle> buildShapes(int level, Random rnd) {
  final shadowCount = level <= 4 ? 2 : 1;
  return [
    for (var i = 0; i < 4; i++)
      if (i < shadowCount) buildShadow(rnd) else buildTile(rnd),
  ];
}
