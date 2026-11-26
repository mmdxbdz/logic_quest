import 'dart:math';
import '../models.dart';
import 'util.dart';

const List<List<String>> _objects = [
  ['🐱', '小猫'],
  ['🐶', '小狗'],
  ['🐰', '小兔'],
  ['🐸', '小青蛙'],
  ['🐤', '小鸟'],
  ['🐼', '熊猫'],
];

const List<List<String>> _references = [
  ['📦', '盒子'],
  ['🌳', '大树'],
  ['🪑', '椅子'],
  ['🚪', '门'],
  ['⛺', '帐篷'],
];

const List<String> _dirs = ['up', 'down', 'left', 'right'];

Puzzle buildPosition(int level, Random rnd) {
  final allowed = level == 1
      ? ['up', 'down']
      : level == 2
          ? ['left', 'right']
          : _dirs;
  final obj = pick(rnd, _objects);
  final ref = pick(rnd, _references);
  final dir = pick(rnd, allowed);
  final options = [
    for (final d in _dirs) OptionSpec(arrow: d),
  ];
  return PositionPuzzle(
    prompt: '${obj[1]}在${ref[1]}的哪边呀？',
    objectEmoji: obj[0],
    referenceEmoji: ref[0],
    direction: dir,
    options: options,
    correct: _dirs.indexOf(dir),
  );
}

const List<List<String>> _mazes3 = [
  ['S..', '.##', '..G'],
  ['S.#', '..#', '#.G'],
  ['S..', '.#.', '..G'],
  ['S..', '..#', '.G.'],
];

const List<List<String>> _mazes34 = [
  ['S.#.', '..G.', '#...'],
  ['S...', '.##.', '...G'],
  ['S...', '.#..', '..G.'],
];

const List<List<String>> _mazes4 = [
  ['S...', '.##.', '.#..', '..G.'],
  ['S...', '.#..', '..##', '...G'],
  ['S.#.', '..##', '.#..', '...G'],
  ['S..#', '.#..', '..##', '...G'],
];

const List<List<String>> _mazes5 = [
  ['S....', '.###.', '.#G#.', '.#...', '.....'],
  ['S...#', '.###.', '.#G#.', '.#...', '.....'],
];

MazePuzzle mazeFromRows(List<String> rows) {
  final cols = rows.first.length;
  final height = rows.length;
  var start = -1;
  var goal = -1;
  final walls = <int>{};
  for (var y = 0; y < height; y++) {
    final row = rows[y];
    for (var x = 0; x < cols; x++) {
      final ch = row[x];
      final idx = y * cols + x;
      if (ch == '#') walls.add(idx);
      if (ch == 'S') start = idx;
      if (ch == 'G') goal = idx;
    }
  }
  final puzzle = MazePuzzle(
    prompt: '带小兔子走到胡萝卜那里吧！',
    cols: cols,
    rows: height,
    walls: walls,
    start: start,
    goal: goal,
    optimal: 0,
  );
  final steps = _bfs(puzzle);
  return MazePuzzle(
    prompt: puzzle.prompt,
    cols: cols,
    rows: height,
    walls: walls,
    start: start,
    goal: goal,
    optimal: steps,
  );
}

int _bfs(MazePuzzle m) {
  final dist = <int, int>{m.start: 0};
  final queue = <int>[m.start];
  var head = 0;
  while (head < queue.length) {
    final cur = queue[head++];
    if (cur == m.goal) return dist[cur]!;
    for (final d in const [
      [0, -1],
      [0, 1],
      [-1, 0],
      [1, 0],
    ]) {
      if (!m.canMove(cur, d[0], d[1])) continue;
      final next = m.move(cur, d[0], d[1]);
      if (dist.containsKey(next)) continue;
      dist[next] = dist[cur]! + 1;
      queue.add(next);
    }
  }
  return -1;
}

MazePuzzle _mazeForLevel(int level, Random rnd) {
  final pool = switch (level) {
    4 => _mazes3,
    5 => [..._mazes3, ..._mazes34],
    6 => _mazes34,
    7 => _mazes4,
    _ => _mazes5,
  };
  final rows = pick(rnd, pool);
  final m = mazeFromRows(rows);
  if (m.optimal > 0) return m;
  return mazeFromRows(_mazes3.first);
}

List<Puzzle> buildSpatial(int level, Random rnd) {
  if (level >= 4) return [_mazeForLevel(level, rnd)];
  return [for (var i = 0; i < 4; i++) buildPosition(level, rnd)];
}

/// 供测试使用：返回全部迷宫模板（按尺寸分组）
Map<String, List<List<String>>> allMazeTemplates() => {
      '3x3': _mazes3,
      '3x4': _mazes34,
      '4x4': _mazes4,
      '5x5': _mazes5,
    };
