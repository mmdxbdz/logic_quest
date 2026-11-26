import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models.dart';
import '../speech.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/mascot.dart';
import '../widgets/stars.dart';
import 'level_router.dart';

class IslandScreen extends StatelessWidget {
  final IslandDef island;
  const IslandScreen({super.key, required this.island});

  @override
  Widget build(BuildContext context) {
    final store = ProgressStore();
    if (!store.islandUnlocked(island.id)) {
      return Scaffold(
        backgroundColor: Palette.cream,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_rounded, size: 64, color: Palette.inkSoft),
                const SizedBox(height: 16),
                const Text(
                  '这个小岛还锁着呢',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Palette.ink),
                ),
                const SizedBox(height: 8),
                const Text(
                  '先把前面的小岛一关一关走完吧',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Palette.inkSoft),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('回去'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Palette.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Palette.ink),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Row(
          children: [
            Text(island.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 8),
            Text(
              island.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Palette.ink,
              ),
            ),
          ],
        ),
      ),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FoxBubble(text: island.tip, foxSize: 42),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      runSpacing: 24,
                      children: [
                        for (var level = 1; level <= ProgressStore.levelsPerIsland; level++)
                          _LevelButton(
                            island: island,
                            level: level,
                            stars: store.starsOf(island.id, level),
                            unlocked: store.isLevelUnlocked(island.id, level),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    '已获得 ${store.islandStars(island.id)} / 24 颗星',
                    style: const TextStyle(fontSize: 13, color: Palette.inkSoft),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LevelButton extends StatelessWidget {
  final IslandDef island;
  final int level;
  final int stars;
  final bool unlocked;
  const _LevelButton({
    required this.island,
    required this.level,
    required this.stars,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!unlocked) {
          HapticFeedback.lightImpact();
          Speech.say('先玩前一关哦。');
          return;
        }
        openLevel(context, island, level);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: unlocked
                  ? (stars > 0 ? island.color : Colors.white)
                  : const Color(0xFFEDEFF1),
              shape: BoxShape.circle,
              border: Border.all(
                color: unlocked ? Colors.white : const Color(0xFFDDE2E6),
                width: 3,
              ),
              boxShadow: unlocked
                  ? [
                      BoxShadow(
                        color: island.color.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: unlocked
                  ? Text(
                      '$level',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: stars > 0 ? Colors.white : Palette.ink,
                      ),
                    )
                  : const Icon(Icons.lock_rounded, color: Color(0xFFB0BAC1), size: 26),
            ),
          ),
          const SizedBox(height: 5),
          stars > 0 ? StarBar(stars: stars, size: 14) : const SizedBox(height: 14),
        ],
      ),
    );
  }
}
