import 'package:flutter/material.dart';
import '../content/stickers.dart';
import '../models.dart';
import '../speech.dart';
import '../theme.dart';
import '../widgets/confetti.dart';
import '../widgets/mascot.dart';
import '../widgets/stars.dart';
import 'level_router.dart';

class ResultScreen extends StatefulWidget {
  final IslandDef island;
  final int level;
  final int stars;
  final List<int> newStickers;
  const ResultScreen({
    super.key,
    required this.island,
    required this.level,
    required this.stars,
    this.newStickers = const [],
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.newStickers.isNotEmpty) {
        Speech.say('这一关闯过啦！还拿到了新贴纸，你真棒！');
      } else {
        Speech.celebrate();
      }
    });
  }

  void _backHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _next() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => levelScreen(widget.island, widget.level + 1),
      ),
    );
  }

  void _replay() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => levelScreen(widget.island, widget.level),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final praise = widget.stars >= 3
        ? '太厉害啦！'
        : widget.stars == 2
            ? '做得很好！'
            : '继续加油！';
    final hasNext = widget.level < 8;
    final newSticker = widget.newStickers.isEmpty ? null : stickers[widget.newStickers.first];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFFDF4), Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
              ),
            ),
          ),
          if (widget.stars >= 2) const Positioned.fill(child: Confetti()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
              child: Column(
                children: [
                  const FoxBuddy(size: 96, cheer: true),
                  const SizedBox(height: 10),
                  Text(
                    '第 ${widget.level} 关 · 完成！',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Palette.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.island.emoji} ${widget.island.name}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Palette.inkSoft,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  BigStars(stars: widget.stars),
                  const SizedBox(height: 6),
                  Text(
                    praise,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Palette.ink,
                    ),
                  ),
                  if (newSticker != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Palette.tangerine.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(newSticker.emoji, style: const TextStyle(fontSize: 38)),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '新贴纸！',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Palette.ink,
                                ),
                              ),
                              Text(
                                newSticker.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Palette.inkSoft,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (!hasNext) ...[
                    const SizedBox(height: 16),
                    const Text(
                      '🏝️ 这座小岛全通关啦！',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Palette.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '去别的岛上玩一玩吧',
                      style: TextStyle(fontSize: 13, color: Palette.inkSoft),
                    ),
                  ],
                  const SizedBox(height: 28),
                  if (hasNext)
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: FilledButton.icon(
                        onPressed: _next,
                        style: FilledButton.styleFrom(
                          backgroundColor: widget.island.color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text(
                          '下一关',
                          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: _backHome,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Palette.inkSoft, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(Icons.home_rounded, color: Palette.ink),
                      label: const Text(
                        '回小岛',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Palette.ink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: _replay,
                    child: const Text(
                      '再玩一次',
                      style: TextStyle(fontSize: 15, color: Palette.inkSoft),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
