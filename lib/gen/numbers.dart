import 'dart:math';
import '../models.dart';
import 'util.dart';

const List<List<String>> _pools = [
  ['🐟', '🦋', '🐞', '🐝', '🐢', '🦀', '🐬', '🐙'],
  ['🍎', '🍓', '🍇', '🍊', '🍋', '🍑', '🍒', '🥝'],
  ['⭐', '❤️', '🌙', '☀️', '🌈', '☁️', '⚡', '❄️'],
  ['🚗', '🚌', '🚲', '🚂', '✈️', '⛵', '🚁', '🚕'],
];

Puzzle buildCount(Random rnd, int max) {
  final emoji = pick(rnd, pick(rnd, _pools));
  final count = ri(rnd, 1, max);
  final options = numberOptions(rnd, count, max: max, count: 3);
  final correct = options.indexWhere((o) => o.text == '$count');
  return CountPuzzle(
    prompt: '数一数，一共有几个呀？',
    emoji: emoji,
    count: count,
    options: options,
    correct: correct < 0 ? 0 : correct,
  );
}

Puzzle buildCompare(Random rnd, int max, {bool close = false}) {
  var a = ri(rnd, 2, max);
  var b = ri(rnd, 2, max);
  var guard = 0;
  while (b == a && guard < 50) {
    b = ri(rnd, 2, max);
    guard++;
  }
  if (b == a) b = a == max ? a - 1 : a + 1;
  if (close && (a - b).abs() > 1) {
    if (a > b) {
      b = a - 1;
    } else {
      a = b - 1;
    }
  }
  final leftEmoji = pick(rnd, pick(rnd, _pools));
  final rightEmoji = pick(rnd, pick(rnd, _pools));
  return ComparePuzzle(
    prompt: '哪边多呀？点一点多的那边。',
    left: List.filled(a, leftEmoji),
    right: List.filled(b, rightEmoji),
    correctSide: a > b ? 0 : 1,
  );
}

Puzzle buildSequence(
  Random rnd,
  int max, {
  int length = 4,
  bool middle = false,
}) {
  final start = ri(rnd, 1, max - length + 1);
  final nums = [for (var i = 0; i < length; i++) start + i];
  final blank = middle ? ri(rnd, 1, length - 1) : length - 1;
  final answer = nums[blank];
  final options = numberOptions(rnd, answer, min: 1, max: 10, count: 3);
  final correct = options.indexWhere((o) => o.text == '$answer');
  return SequencePuzzle(
    prompt: blank == length - 1 ? '后面应该是几呀？' : '中间少了哪个数字呀？',
    numbers: nums,
    blankIndex: blank,
    options: options,
    correct: correct < 0 ? 0 : correct,
  );
}

Puzzle buildEqual(Random rnd, int max) {
  final targetCount = ri(rnd, 2, max);
  final targetEmoji = pick(rnd, pick(rnd, _pools));
  var optionEmoji = pick(rnd, pick(rnd, _pools));
  var guard = 0;
  while (optionEmoji == targetEmoji && guard < 30) {
    optionEmoji = pick(rnd, pick(rnd, _pools));
    guard++;
  }
  final counts = <int>{targetCount};
  guard = 0;
  while (counts.length < 3 && guard < 100) {
    guard++;
    final delta = ri(rnd, 1, 2) * (rnd.nextBool() ? 1 : -1);
    final v = targetCount + delta;
    if (v >= 1 && v <= max) counts.add(v);
  }
  var extra = 1;
  while (counts.length < 3) {
    if (targetCount + extra <= max) counts.add(targetCount + extra);
    if (counts.length < 3 && targetCount - extra >= 1) counts.add(targetCount - extra);
    extra++;
  }
  final groupCounts = counts.toList()..shuffle(rnd);
  final groups = <List<String>>[
    for (final c in groupCounts) List.filled(c, optionEmoji),
  ];
  return EqualPuzzle(
    prompt: '哪一排和上面一样多呀？',
    target: List.filled(targetCount, targetEmoji),
    groups: groups,
    correct: groupCounts.indexOf(targetCount),
  );
}

List<Puzzle> buildNumbers(int level, Random rnd) {
  final max = level <= 2 ? 5 : (level <= 4 ? 8 : 10);
  switch (level) {
    case 1:
      return [
        buildCount(rnd, max),
        buildCount(rnd, max),
        buildCompare(rnd, max),
        buildCompare(rnd, max),
      ];
    case 2:
      return [
        buildCount(rnd, max),
        buildCount(rnd, max),
        buildCompare(rnd, max),
        buildCount(rnd, max),
      ];
    case 3:
      return [
        buildCount(rnd, max),
        buildCompare(rnd, max),
        buildSequence(rnd, max),
        buildSequence(rnd, max),
      ];
    case 4:
      return [
        buildCount(rnd, max),
        buildSequence(rnd, max),
        buildCompare(rnd, max),
        buildEqual(rnd, 6),
      ];
    case 5:
      return [
        buildCount(rnd, max),
        buildSequence(rnd, 9, length: 5, middle: true),
        buildEqual(rnd, 7),
        buildCompare(rnd, max),
      ];
    case 6:
      return [
        buildSequence(rnd, 9, length: 5, middle: true),
        buildEqual(rnd, 8),
        buildCount(rnd, max),
        buildCompare(rnd, max, close: true),
      ];
    case 7:
      return [
        buildSequence(rnd, 9, length: 5, middle: true),
        buildEqual(rnd, 8),
        buildCompare(rnd, max, close: true),
        buildCount(rnd, max),
      ];
    default:
      return [
        buildCount(rnd, max),
        buildSequence(rnd, 9, length: 5, middle: true),
        buildEqual(rnd, 8),
        buildCompare(rnd, max, close: true),
      ];
  }
}
