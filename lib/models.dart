import 'dart:ui' show Color;

/// 六个思维小岛
enum IslandKind { pattern, classify, spatial, number, memory, shape }

class IslandDef {
  final IslandKind kind;
  final String id;
  final String emoji;
  final String name;
  final String tip;
  final Color color;
  const IslandDef({
    required this.kind,
    required this.id,
    required this.emoji,
    required this.name,
    required this.tip,
    required this.color,
  });
}

/// 一个可点的答案/卡片
class OptionSpec {
  final String? emoji; // 一个大的表情
  final String? text; // 数字等文字
  final List<String>? group; // 一排小表情（比多少、一样多）
  final String? shape; // 几何图形符号 ● ■ ▲ ★ ◆
  final Color? color; // 图形颜色
  final String? arrow; // up / down / left / right

  const OptionSpec({
    this.emoji,
    this.text,
    this.group,
    this.shape,
    this.color,
    this.arrow,
  });
}

abstract class Puzzle {
  const Puzzle();
  String get prompt;
}

class PatternPuzzle extends Puzzle {
  @override
  final String prompt;
  final List<String> sequence;
  final List<OptionSpec> options;
  final int correct;
  const PatternPuzzle({
    required this.prompt,
    required this.sequence,
    required this.options,
    required this.correct,
  });
}

class ClassifyPuzzle extends Puzzle {
  @override
  final String prompt;
  final List<OptionSpec> options;
  final Set<int> correct;
  final bool pair; // true = 找出一样的两个
  const ClassifyPuzzle({
    required this.prompt,
    required this.options,
    required this.correct,
    required this.pair,
  });
}

class PositionPuzzle extends Puzzle {
  @override
  final String prompt;
  final String objectEmoji;
  final String referenceEmoji;
  final String direction; // up / down / left / right
  final List<OptionSpec> options;
  final int correct;
  const PositionPuzzle({
    required this.prompt,
    required this.objectEmoji,
    required this.referenceEmoji,
    required this.direction,
    required this.options,
    required this.correct,
  });
}

class CountPuzzle extends Puzzle {
  @override
  final String prompt;
  final String emoji;
  final int count;
  final List<OptionSpec> options;
  final int correct;
  const CountPuzzle({
    required this.prompt,
    required this.emoji,
    required this.count,
    required this.options,
    required this.correct,
  });
}

class ComparePuzzle extends Puzzle {
  @override
  final String prompt;
  final List<String> left;
  final List<String> right;
  final int correctSide; // 0 = 左边多，1 = 右边多
  const ComparePuzzle({
    required this.prompt,
    required this.left,
    required this.right,
    required this.correctSide,
  });
}

class SequencePuzzle extends Puzzle {
  @override
  final String prompt;
  final List<int> numbers;
  final int blankIndex;
  final List<OptionSpec> options;
  final int correct;
  const SequencePuzzle({
    required this.prompt,
    required this.numbers,
    required this.blankIndex,
    required this.options,
    required this.correct,
  });
}

class EqualPuzzle extends Puzzle {
  @override
  final String prompt;
  final List<String> target;
  final List<List<String>> groups;
  final int correct;
  const EqualPuzzle({
    required this.prompt,
    required this.target,
    required this.groups,
    required this.correct,
  });
}

class ShadowPuzzle extends Puzzle {
  @override
  final String prompt;
  final String silhouetteEmoji;
  final List<OptionSpec> options;
  final int correct;
  const ShadowPuzzle({
    required this.prompt,
    required this.silhouetteEmoji,
    required this.options,
    required this.correct,
  });
}

class TilePuzzle extends Puzzle {
  @override
  final String prompt;
  final int cols;
  final int rows;
  final List<OptionSpec> tiles;
  final int blankIndex;
  final List<OptionSpec> options;
  final int correct;
  const TilePuzzle({
    required this.prompt,
    required this.cols,
    required this.rows,
    required this.tiles,
    required this.blankIndex,
    required this.options,
    required this.correct,
  });
}

class MazePuzzle extends Puzzle {
  @override
  final String prompt;
  final int cols;
  final int rows;
  final Set<int> walls;
  final int start;
  final int goal;
  final int optimal;

  const MazePuzzle({
    required this.prompt,
    required this.cols,
    required this.rows,
    required this.walls,
    required this.start,
    required this.goal,
    required this.optimal,
  });

  bool isWall(int index) => walls.contains(index);

  bool canMove(int index, int dx, int dy) {
    final x = index % cols + dx;
    final y = index ~/ cols + dy;
    if (x < 0 || y < 0 || x >= cols || y >= rows) return false;
    return !isWall(y * cols + x);
  }

  int move(int index, int dx, int dy) => (index ~/ cols + dy) * cols + (index % cols + dx);
}

class MemoryPuzzle extends Puzzle {
  @override
  final String prompt;
  final List<String> cards;
  final int cols;
  final int pairs;
  const MemoryPuzzle({
    required this.prompt,
    required this.cards,
    required this.cols,
    required this.pairs,
  });

  int get rows => (cards.length + cols - 1) ~/ cols;
}
