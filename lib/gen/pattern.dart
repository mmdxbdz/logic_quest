import 'dart:math';
import '../models.dart';
import 'util.dart';

class _Spec {
  final String unit;
  final int shown;
  final int opts;
  const _Spec(this.unit, this.shown, this.opts);
}

const List<_Spec> _specs = [
  _Spec('AB', 4, 3),
  _Spec('AABB', 4, 3),
  _Spec('ABC', 4, 3),
  _Spec('ABB', 5, 3),
  _Spec('ABC', 5, 4),
  _Spec('ABAB', 6, 4),
  _Spec('AABB', 6, 4),
  _Spec('ABC', 6, 4),
];

const List<List<String>> _pools = [
  ['🔴', '🔵', '🟡', '🟢', '🟣', '🟠'],
  ['🐶', '🐱', '🐰', '🐸', '🐼', '🦊'],
  ['🍎', '🍌', '🍇', '🍓', '🍉', '🍑'],
  ['🚗', '🚌', '🚕', '🚲', '🚂', '🚁'],
  ['⭐', '❤️', '🌙', '☀️', '🌈', '☁️'],
];

Puzzle buildPatternPuzzle(int level, Random rnd) {
  final spec = _specs[(level - 1).clamp(0, _specs.length - 1)];
  final symbols = shuffled(rnd, pick(rnd, _pools));
  final unit = spec.unit.split('');
  final letters = unit.toSet().toList()..sort();
  final map = <String, String>{};
  for (var i = 0; i < letters.length; i++) {
    map[letters[i]] = symbols[i];
  }
  final seq = <String>[
    for (var i = 0; i < spec.shown; i++) map[unit[i % unit.length]]!,
  ];
  final answer = map[unit[spec.shown % unit.length]]!;
  final others = symbols.where((s) => s != answer).take(spec.opts - 1).toList();
  final options = [...others, answer]..shuffle(rnd);
  return PatternPuzzle(
    prompt: '接下来是什么呀？',
    sequence: seq,
    options: [for (final e in options) OptionSpec(emoji: e)],
    correct: options.indexOf(answer),
  );
}

List<Puzzle> buildPattern(int level, Random rnd) =>
    [for (var i = 0; i < 4; i++) buildPatternPuzzle(level, rnd)];
