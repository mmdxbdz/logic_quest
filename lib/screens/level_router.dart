import 'package:flutter/material.dart';
import '../models.dart';
import 'choice_game.dart';
import 'maze_game.dart';
import 'memory_game.dart';

/// 根据岛和关卡选择对应的游戏界面
Widget levelScreen(IslandDef island, int level) {
  if (island.kind == IslandKind.memory) {
    return MemoryGameScreen(island: island, level: level);
  }
  if (island.kind == IslandKind.spatial && level >= 4) {
    return MazeGameScreen(island: island, level: level);
  }
  return ChoiceGameScreen(island: island, level: level);
}

void openLevel(BuildContext context, IslandDef island, int level) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => levelScreen(island, level)),
  );
}
