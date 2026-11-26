import 'dart:math';
import '../models.dart';
import 'util.dart';

const Map<String, List<String>> _cats = {
  'fruit': ['🍎', '🍌', '🍇', '🍓', '🍉', '🍊', '🍑', '🍍', '🥝'],
  'animal': ['🐶', '🐱', '🐰', '🐷', '🐮', '🐸', '🐵', '🦁', '🐯'],
  'vehicle': ['🚗', '🚌', '🚑', '🚕', '🚲', '🚂', '✈️', '🚚', '⛵'],
  'toy': ['🧸', '🪀', '🪁', '🎈', '🎲', '🤖'],
  'clothes': ['👕', '👖', '👗', '🧢', '🧦', '🧤', '👟'],
  'food': ['🍞', '🍕', '🍔', '🍟', '🥪', '🍩', '🍪'],
  'furniture': ['🛋️', '🪑', '🛏️', '🚪', '🪟'],
  'nature': ['🌳', '🌷', '🌻', '🍁', '🌵', '🌲'],
};

const List<List<String>> _closePairs = [
  ['fruit', 'food'],
  ['animal', 'nature'],
  ['vehicle', 'toy'],
  ['clothes', 'furniture'],
];

List<String> _allEmojis() {
  final out = <String>[];
  for (final list in _cats.values) {
    for (final e in list) {
      if (!out.contains(e)) out.add(e);
    }
  }
  return out;
}

Puzzle buildOddOneOut(int level, Random rnd) {
  late final String major;
  late final String odd;
  if (level <= 3) {
    final cats = _cats.keys.toList()..shuffle(rnd);
    major = cats[0];
    odd = cats[1];
  } else {
    final pair = pick(rnd, _closePairs);
    major = pair[0];
    odd = pair[1];
  }
  final majority = shuffled(rnd, _cats[major]!).take(3).toList();
  final oddEmoji = pick(rnd, _cats[odd]!);
  final items = [...majority, oddEmoji]..shuffle(rnd);
  return ClassifyPuzzle(
    prompt: '哪个不一样呀？',
    options: [for (final e in items) OptionSpec(emoji: e)],
    correct: {items.indexOf(oddEmoji)},
    pair: false,
  );
}

Puzzle buildPair(Random rnd) {
  final all = _allEmojis();
  final base = pick(rnd, all);
  final others = shuffled(rnd, all.where((e) => e != base).toList()).take(3).toList();
  final items = [base, base, ...others]..shuffle(rnd);
  final correct = <int>{};
  for (var i = 0; i < items.length; i++) {
    if (items[i] == base) correct.add(i);
  }
  return ClassifyPuzzle(
    prompt: '哪两个是一样的呀？',
    options: [for (final e in items) OptionSpec(emoji: e)],
    correct: correct,
    pair: true,
  );
}

List<Puzzle> buildClassify(int level, Random rnd) {
  final pairCount = level >= 7 ? 2 : (level >= 4 ? 1 : 0);
  final list = <Puzzle>[];
  for (var i = 0; i < 4; i++) {
    if (pairCount > 0 && i >= 4 - pairCount) {
      list.add(buildPair(rnd));
    } else {
      list.add(buildOddOneOut(level, rnd));
    }
  }
  return list;
}
