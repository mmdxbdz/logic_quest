import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_quest/gen/classify.dart';
import 'package:logic_quest/gen/levels.dart';
import 'package:logic_quest/gen/memory.dart';
import 'package:logic_quest/gen/numbers.dart';
import 'package:logic_quest/gen/pattern.dart';
import 'package:logic_quest/gen/shapes.dart';
import 'package:logic_quest/gen/spatial.dart';
import 'package:logic_quest/models.dart';

int _minPeriod(List<String> seq) {
  for (var p = 1; p <= seq.length; p++) {
    var ok = true;
    for (var i = 0; i < seq.length; i++) {
      if (seq[i] != seq[i % p]) {
        ok = false;
        break;
      }
    }
    if (ok) return p;
  }
  return seq.length;
}

void main() {
  group('找规律', () {
    test('序列符合规律，正确选项是下一个', () {
      for (var level = 1; level <= 8; level++) {
        for (var i = 0; i < 30; i++) {
          final p = buildPatternPuzzle(level, Random(1000 + level * 31 + i)) as PatternPuzzle;
          expect(p.sequence.length, greaterThanOrEqualTo(4));
          expect(p.options.length, inInclusiveRange(3, 4));
          expect(p.options[p.correct].emoji, isNotNull);
          final options = p.options.map((o) => o.emoji).toList();
          expect(options.toSet().length, options.length, reason: '选项不应重复');
          final period = _minPeriod(p.sequence);
          final expected = p.sequence[p.sequence.length % period];
          expect(p.options[p.correct].emoji, expected);
        }
      }
    });
  });

  group('分类配对', () {
    test('找不同只有一个答案；配对正好两个一样', () {
      for (var level = 1; level <= 8; level++) {
        for (var i = 0; i < 20; i++) {
          final puzzles = buildClassify(level, Random(2000 + level * 17 + i));
          for (final p in puzzles.cast<ClassifyPuzzle>()) {
            if (p.pair) {
              expect(p.options.length, 5);
              expect(p.correct.length, 2);
              final emojis = p.correct.map((i) => p.options[i].emoji).toSet();
              expect(emojis.length, 1);
              final all = p.options.map((o) => o.emoji).toList();
              expect(all.where((e) => e == emojis.first).length, 2);
            } else {
              expect(p.options.length, 4);
              expect(p.correct.length, 1);
              final all = p.options.map((o) => o.emoji).toList();
              expect(all.toSet().length, 4);
            }
          }
        }
      }
    });
  });

  group('空间方位', () {
    test('上下左右的答案与场景一致', () {
      for (var level = 1; level <= 3; level++) {
        for (var i = 0; i < 20; i++) {
          final puzzles = buildSpatial(level, Random(3000 + level * 11 + i));
          for (final p in puzzles.cast<PositionPuzzle>()) {
            expect(p.options.length, 4);
            expect(p.options[p.correct].arrow, p.direction);
            if (level == 1) expect(p.direction, anyOf('up', 'down'));
            if (level == 2) expect(p.direction, anyOf('left', 'right'));
          }
        }
      }
    });

    test('所有迷宫模板都可以走到终点', () {
      final all = allMazeTemplates();
      for (final entry in all.entries) {
        for (final rows in entry.value) {
          final m = mazeFromRows(rows);
          expect(m.optimal, greaterThan(0), reason: '迷宫不可达: ${entry.key} $rows');
          expect(m.walls.contains(m.start), isFalse);
          expect(m.walls.contains(m.goal), isFalse);
        }
      }
      for (var level = 4; level <= 8; level++) {
        for (var i = 0; i < 10; i++) {
          final m = buildSpatial(level, Random(4000 + level * 7 + i)).single as MazePuzzle;
          expect(m.optimal, greaterThan(0));
        }
      }
    });
  });

  group('数与量', () {
    test('数一数、比多少、数字接龙、一样多都正确', () {
      for (var level = 1; level <= 8; level++) {
        for (var i = 0; i < 20; i++) {
          final puzzles = buildNumbers(level, Random(5000 + level * 13 + i));
          expect(puzzles.length, 4);
          for (final p in puzzles) {
            if (p is CountPuzzle) {
              expect(p.count, inInclusiveRange(1, 10));
              expect(p.options[p.correct].text, '${p.count}');
            } else if (p is ComparePuzzle) {
              expect(p.left.length, isNot(p.right.length));
              final expected = p.left.length > p.right.length ? 0 : 1;
              expect(p.correctSide, expected);
            } else if (p is SequencePuzzle) {
              expect(p.blankIndex, greaterThan(0));
              expect(p.numbers[p.blankIndex], int.parse(p.options[p.correct].text!));
              for (var k = 1; k < p.numbers.length; k++) {
                expect(p.numbers[k], p.numbers[k - 1] + 1);
              }
            } else if (p is EqualPuzzle) {
              expect(p.groups[p.correct].length, p.target.length);
              final counts = p.groups.map((g) => g.length).toSet();
              expect(counts.length, 3);
            } else {
              fail('未知题型 ${p.runtimeType}');
            }
          }
        }
      }
    });
  });

  group('翻牌记忆', () {
    test('每种图案正好两张', () {
      for (var level = 1; level <= 8; level++) {
        for (var i = 0; i < 20; i++) {
          final m = buildMemory(level, Random(6000 + level * 19 + i)) as MemoryPuzzle;
          expect(m.cards.length, m.pairs * 2);
          final counts = <String, int>{};
          for (final c in m.cards) {
            counts[c] = (counts[c] ?? 0) + 1;
          }
          expect(counts.values.every((v) => v == 2), isTrue);
          expect(m.cols, inInclusiveRange(2, 5));
          expect(m.rows * m.cols, greaterThanOrEqualTo(m.cards.length));
        }
      }
    });
  });

  group('图形拼搭', () {
    test('影子与拼图缺块正确', () {
      for (var level = 1; level <= 8; level++) {
        for (var i = 0; i < 20; i++) {
          final puzzles = buildShapes(level, Random(7000 + level * 23 + i));
          for (final p in puzzles) {
            if (p is ShadowPuzzle) {
              expect(p.options[p.correct].emoji, p.silhouetteEmoji);
            } else if (p is TilePuzzle) {
              final blank = p.tiles[p.blankIndex];
              final answer = p.options[p.correct];
              expect(answer.shape, blank.shape);
              expect(answer.color, blank.color);
              final pairs = p.options.map((o) => '${o.shape}|${o.color?.toARGB32()}').toList();
              expect(pairs.toSet().length, pairs.length);
            } else {
              fail('未知题型');
            }
          }
        }
      }
    });
  });

  test('所有岛的 48 个关卡都能生成题目', () {
    for (final kind in IslandKind.values) {
      for (var level = 1; level <= 8; level++) {
        final puzzles = buildPuzzles(kind, level, Random(99 + level));
        expect(puzzles, isNotEmpty);
      }
    }
  });
}
