import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../gen/levels.dart';
import '../models.dart';
import '../screens/result.dart';
import '../soundfx.dart';
import '../speech.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/mascot.dart';

class MemoryGameScreen extends StatefulWidget {
  final IslandDef island;
  final int level;
  const MemoryGameScreen({super.key, required this.island, required this.level});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  late final MemoryPuzzle _puzzle;
  final Set<int> _open = {};
  final Set<int> _matched = {};
  int? _first;
  int _moves = 0;
  bool _busy = false;
  bool _finishing = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _puzzle = buildPuzzles(widget.island.kind, widget.level, Random()).first
        as MemoryPuzzle;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Speech.say(_puzzle.prompt);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tap(int i) {
    if (_busy || _matched.contains(i) || _open.contains(i)) return;
    SoundFx.pop();
    setState(() => _open.add(i));
    final first = _first;
    if (first == null) {
      _first = i;
      return;
    }
    _first = null;
    _moves++;
    if (_puzzle.cards[first] == _puzzle.cards[i]) {
      SoundFx.ding();
      Speech.cheer();
      setState(() {
        _matched.addAll([first, i]);
        _open.removeAll([first, i]);
      });
      if (_matched.length >= _puzzle.cards.length) {
        _timer = Timer(const Duration(milliseconds: 900), _finish);
      }
    } else {
      _busy = true;
      SoundFx.boop();
      _timer = Timer(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          _open.removeAll([first, i]);
          _busy = false;
        });
      });
    }
  }

  int get _stars {
    if (_moves <= _puzzle.pairs + 2) return 3;
    if (_moves <= _puzzle.pairs + 5) return 2;
    return 1;
  }

  Future<void> _finish() async {
    if (_finishing) return;
    _finishing = true;
    final newStickers =
        await ProgressStore().recordLevel(widget.island.id, widget.level, _stars);
    if (!mounted) return;
    SoundFx.tada();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          island: widget.island,
          level: widget.level,
          stars: _stars,
          newStickers: newStickers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pairsFound = _matched.length ~/ 2;
    return Scaffold(
      backgroundColor: Palette.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            children: [
              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.close_rounded, color: Palette.inkSoft),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${widget.island.emoji} 翻牌记忆 · 第 ${widget.level} 关',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Palette.ink,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '配对 $pairsFound/${_puzzle.pairs}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Palette.inkSoft,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              FoxBubble(text: _puzzle.prompt, foxSize: 42),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = _puzzle.cols;
                      const gap = 8.0;
                      final available = constraints.maxWidth;
                      var size = (available - gap * (cols - 1)) / cols;
                      size = size.clamp(44.0, 92.0);
                      return SizedBox(
                        width: size * cols + gap * (cols - 1),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: gap,
                          runSpacing: gap,
                          children: [
                            for (var i = 0; i < _puzzle.cards.length; i++)
                              _Card(
                                size: size,
                                emoji: _puzzle.cards[i],
                                open: _open.contains(i) || _matched.contains(i),
                                matched: _matched.contains(i),
                                onTap: () => _tap(i),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '翻开两张一样的卡片，把它们配成一对',
                style: TextStyle(
                  fontSize: 13,
                  color: Palette.inkSoft.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final double size;
  final String emoji;
  final bool open;
  final bool matched;
  final VoidCallback onTap;

  const _Card({
    required this.size,
    required this.emoji,
    required this.open,
    required this.matched,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: matched
              ? const Color(0xFFE8F5E9)
              : open
                  ? Colors.white
                  : const Color(0xFFB39DDB),
          borderRadius: BorderRadius.circular(size * 0.22),
          border: Border.all(
            color: matched
                ? Palette.good
                : open
                    ? const Color(0xFFE8EDF0)
                    : Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              open ? emoji : '🐚',
              key: ValueKey<bool>(open),
              style: TextStyle(fontSize: size * 0.52, height: 1.0),
            ),
          ),
        ),
      ),
    );
  }
}
