import 'dart:math';
import '../models.dart';
import 'pattern.dart';
import 'classify.dart';
import 'spatial.dart';
import 'numbers.dart';
import 'memory.dart';
import 'shapes.dart';

/// 生成某个岛的某一关题目。
List<Puzzle> buildPuzzles(IslandKind kind, int level, Random rnd) {
  switch (kind) {
    case IslandKind.pattern:
      return buildPattern(level, rnd);
    case IslandKind.classify:
      return buildClassify(level, rnd);
    case IslandKind.spatial:
      return buildSpatial(level, rnd);
    case IslandKind.number:
      return buildNumbers(level, rnd);
    case IslandKind.memory:
      return [buildMemory(level, rnd)];
    case IslandKind.shape:
      return buildShapes(level, rnd);
  }
}
