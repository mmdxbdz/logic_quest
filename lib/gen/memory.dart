import 'dart:math';
import '../models.dart';
import 'util.dart';

const List<String> _pool = [
  '🐶', '🐱', '🐰', '🐸', '🐼', '🦊', '🦁', '🐷',
  '🍎', '🍌', '🍇', '🍓', '🍉', '🍑',
  '🚗', '🚌', '🚲', '🚂', '✈️', '⛵',
  '⭐', '❤️', '🌈', '☀️', '🌙', '🎈',
];

const List<int> _pairs = [2, 2, 3, 3, 4, 4, 5, 6];

Puzzle buildMemory(int level, Random rnd) {
  final pairs = _pairs[(level - 1).clamp(0, _pairs.length - 1)];
  final cols = switch (pairs) {
    2 => 2,
    3 => 3,
    4 => 4,
    5 => 5,
    _ => 4,
  };
  final chosen = shuffled(rnd, _pool).take(pairs).toList();
  final cards = [...chosen, ...chosen]..shuffle(rnd);
  return MemoryPuzzle(
    prompt: '翻开卡片，把一样的配成一对吧！',
    cards: cards,
    cols: cols,
    pairs: pairs,
  );
}
