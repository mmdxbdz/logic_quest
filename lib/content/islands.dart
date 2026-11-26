import '../models.dart';
import '../theme.dart';

const List<IslandDef> islands = [
  IslandDef(
    kind: IslandKind.pattern,
    id: 'pattern',
    emoji: '🎨',
    name: '找规律',
    tip: '接下来是什么呀？',
    color: Palette.coral,
  ),
  IslandDef(
    kind: IslandKind.classify,
    id: 'classify',
    emoji: '🧺',
    name: '分类配对',
    tip: '哪个不一样？哪两个一样？',
    color: Palette.mint,
  ),
  IslandDef(
    kind: IslandKind.spatial,
    id: 'spatial',
    emoji: '🧭',
    name: '空间方位',
    tip: '上下左右分清楚，帮小兔走迷宫。',
    color: Palette.skyBlue,
  ),
  IslandDef(
    kind: IslandKind.number,
    id: 'number',
    emoji: '🔢',
    name: '数与量',
    tip: '数一数、比一比、找数字。',
    color: Palette.tangerine,
  ),
  IslandDef(
    kind: IslandKind.memory,
    id: 'memory',
    emoji: '🃏',
    name: '翻牌记忆',
    tip: '翻开卡片，把一样的配成一对。',
    color: Palette.lilac,
  ),
  IslandDef(
    kind: IslandKind.shape,
    id: 'shape',
    emoji: '🧩',
    name: '图形拼搭',
    tip: '影子是谁的？拼图缺了哪块？',
    color: Palette.leaf,
  ),
];

IslandDef islandById(String id) => islands.firstWhere((i) => i.id == id);
