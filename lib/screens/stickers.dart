import 'package:flutter/material.dart';
import '../content/stickers.dart';
import '../speech.dart';
import '../store.dart';
import '../theme.dart';

class StickersScreen extends StatelessWidget {
  const StickersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ProgressStore();
    return Scaffold(
      backgroundColor: Palette.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Palette.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '我的贴纸册',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: Palette.ink),
        ),
      ),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final count = store.stickerCount;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Row(
                  children: [
                    const Text('🏅', style: TextStyle(fontSize: 26)),
                    const SizedBox(width: 8),
                    Text(
                      '已收集 $count/24 张',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Palette.ink,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      store.stickerCount >= 24
                          ? '全部集齐啦！'
                          : '还差 ${store.nextStickerStars - store.totalStars} 颗星',
                      style: const TextStyle(fontSize: 12, color: Palette.inkSoft),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.92,
                  ),
                  itemCount: stickers.length,
                  itemBuilder: (context, i) {
                    final unlocked = i < count;
                    return GestureDetector(
                      onTap: () {
                        if (!unlocked) {
                          Speech.say('再得星星就能解锁新贴纸啦。');
                          return;
                        }
                        Speech.say('这是${stickers[i].name}的贴纸，真好看！');
                        showDialog<void>(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  stickers[i].emoji,
                                  style: const TextStyle(fontSize: 72),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  stickers[i].name,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Palette.ink,
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('好'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: unlocked ? Colors.white : const Color(0xFFF2F4F6),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: unlocked ? const Color(0xFFFFE082) : const Color(0xFFE3E8EC),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              unlocked ? stickers[i].emoji : '❔',
                              style: TextStyle(
                                fontSize: 34,
                                color: unlocked ? null : const Color(0xFFC5CDD3),
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              unlocked ? stickers[i].name : '未解锁',
                              style: TextStyle(
                                fontSize: 11,
                                color: unlocked ? Palette.inkSoft : const Color(0xFFB8C0C6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
