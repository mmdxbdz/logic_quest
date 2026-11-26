import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';
import 'option_tile.dart';
import 'mascot.dart';

/// 根据题目类型渲染画面和答案
class PuzzleView extends StatelessWidget {
  final Puzzle puzzle;
  final Set<int> selected;
  final Set<int> revealed;
  final Set<int> wrong;
  final bool locked;
  final Color accent;
  final ValueChanged<int> onTap;

  const PuzzleView({
    super.key,
    required this.puzzle,
    required this.accent,
    required this.onTap,
    this.selected = const {},
    this.revealed = const {},
    this.wrong = const {},
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = puzzle;
    if (p is PatternPuzzle) return _pattern(p);
    if (p is ClassifyPuzzle) return _classify(p);
    if (p is PositionPuzzle) return _position(p);
    if (p is CountPuzzle) return _count(p);
    if (p is ComparePuzzle) return _compare(p);
    if (p is SequencePuzzle) return _sequence(p);
    if (p is EqualPuzzle) return _equal(p);
    if (p is ShadowPuzzle) return _shadow(p);
    if (p is TilePuzzle) return _tile(p);
    return const SizedBox.shrink();
  }

  Widget _options(List<OptionSpec> options, {double size = 82}) => OptionGrid(
        options: options,
        accent: accent,
        selected: selected,
        revealed: revealed,
        wrong: wrong,
        enabled: !locked,
        size: size,
        onTap: onTap,
      );

  Widget _pattern(PatternPuzzle p) {
    final blank = revealed.isEmpty ? '?' : (p.options[p.correct].emoji ?? '✓');
    return _column(
      visual: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final e in p.sequence) EmojiTile(emoji: e, size: 50),
          EmojiTile(emoji: blank, size: 50, highlight: true),
        ],
      ),
      options: _options(p.options, size: 70),
    );
  }

  Widget _classify(ClassifyPuzzle p) {
    final size = p.options.length > 4 ? 70.0 : 94.0;
    return _column(
      visual: FoxBubble(
        text: p.pair ? '找一找，哪两个是一样的？' : '仔细看看，哪一个不一样？',
        foxSize: 42,
      ),
      options: _options(p.options, size: size),
    );
  }

  Widget _position(PositionPuzzle p) {
    return _column(
      visual: PositionScene(
        objectEmoji: p.objectEmoji,
        referenceEmoji: p.referenceEmoji,
        direction: p.direction,
      ),
      options: _options(p.options, size: 78),
    );
  }

  Widget _count(CountPuzzle p) {
    return _column(
      visual: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            for (var i = 0; i < p.count; i++)
              Text(p.emoji, style: const TextStyle(fontSize: 38, height: 1.1)),
          ],
        ),
      ),
      options: _options(p.options, size: 78),
    );
  }

  Widget _compare(ComparePuzzle p) {
    Widget panel(int side, List<String> group) {
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: locked ? null : () => onTap(side),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: revealed.contains(side)
                  ? const Color(0xFFE8F5E9)
                  : wrong.contains(side)
                      ? const Color(0xFFFFEBEE)
                      : Colors.white.withValues(alpha: locked ? 0.55 : 0.95),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: revealed.contains(side)
                    ? Palette.good
                    : wrong.contains(side)
                        ? Palette.bad
                        : selected.contains(side)
                            ? accent
                            : Colors.white,
                width: 3.5,
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,
                runSpacing: 4,
                children: [
                  for (final e in group)
                    Text(e, style: const TextStyle(fontSize: 26, height: 1.1)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 4),
        Expanded(
          child: Row(
            children: [
              panel(0, p.left),
              const SizedBox(width: 12),
              panel(1, p.right),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '点一点多的那边',
          style: TextStyle(fontSize: 14, color: Palette.inkSoft),
        ),
      ],
    );
  }

  Widget _sequence(SequencePuzzle p) {
    return _column(
      visual: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < p.numbers.length; i++)
            NumberTile(
              text: i == p.blankIndex ? '?' : '${p.numbers[i]}',
              highlight: i == p.blankIndex,
              size: 46,
            ),
        ],
      ),
      options: _options(p.options, size: 74),
    );
  }

  Widget _equal(EqualPuzzle p) {
    return Column(
      children: [
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              for (final e in p.target)
                Text(e, style: const TextStyle(fontSize: 30, height: 1.1)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: Center(
            child: OptionGrid(
              options: [
                for (final g in p.groups) OptionSpec(group: g),
              ],
              accent: accent,
              selected: selected,
              revealed: revealed,
              wrong: wrong,
              enabled: !locked,
              size: 92,
              onTap: onTap,
            ),
          ),
        ),
      ],
    );
  }

  Widget _shadow(ShadowPuzzle p) {
    return _column(
      visual: Container(
        width: 132,
        height: 132,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFDDE3E8), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(Color(0xFF37474F), BlendMode.srcIn),
            child: Text(
              p.silhouetteEmoji,
              style: const TextStyle(fontSize: 72, height: 1.0),
            ),
          ),
        ),
      ),
      options: _options(p.options, size: 80),
    );
  }

  Widget _tile(TilePuzzle p) {
    return Column(
      children: [
        const SizedBox(height: 4),
        Expanded(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var r = 0; r < p.rows; r++)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var c = 0; c < p.cols; c++)
                          Padding(
                            padding: const EdgeInsets.all(3),
                            child: ShapeCell(
                              spec: p.tiles[r * p.cols + c],
                              blank: r * p.cols + c == p.blankIndex,
                              size: 54,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _options(p.options, size: 64),
      ],
    );
  }

  Widget _column({required Widget visual, required Widget options}) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: visual,
            ),
          ),
        ),
        const SizedBox(height: 14),
        options,
      ],
    );
  }
}

class EmojiTile extends StatelessWidget {
  final String emoji;
  final double size;
  final bool highlight;
  const EmojiTile({super.key, required this.emoji, this.size = 54, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: highlight ? const Color(0xFFFFF8E1) : Colors.white,
          borderRadius: BorderRadius.circular(size * 0.28),
          border: Border.all(
            color: highlight ? const Color(0xFFFFD54F) : const Color(0xFFE8EDF0),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            emoji,
            style: TextStyle(fontSize: size * 0.56, height: 1.0, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class NumberTile extends StatelessWidget {
  final String text;
  final bool highlight;
  final double size;
  const NumberTile({super.key, required this.text, this.size = 46, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: highlight ? const Color(0xFFFFF8E1) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: highlight ? const Color(0xFFFFD54F) : const Color(0xFFE8EDF0),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: size * 0.44,
              fontWeight: FontWeight.w800,
              color: Palette.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class ShapeCell extends StatelessWidget {
  final OptionSpec spec;
  final bool blank;
  final double size;
  const ShapeCell({super.key, required this.spec, this.blank = false, this.size = 54});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: blank ? const Color(0xFFFFF3E0) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: blank ? const Color(0xFFFFB74D) : const Color(0xFFE8EDF0),
          width: blank ? 2.5 : 1.5,
        ),
      ),
      child: Center(
        child: blank
            ? const Text('?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFFFF9800)))
            : Text(
                spec.shape ?? '',
                style: TextStyle(
                  fontSize: size * 0.56,
                  height: 1.0,
                  color: spec.color,
                  fontWeight: FontWeight.w900,
                ),
              ),
      ),
    );
  }
}

/// 上下左右的场景：中间是参照物，小动物在某个方向
class PositionScene extends StatelessWidget {
  final String objectEmoji;
  final String referenceEmoji;
  final String direction;
  const PositionScene({
    super.key,
    required this.objectEmoji,
    required this.referenceEmoji,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) {
    final row = direction == 'up'
        ? 0
        : direction == 'down'
            ? 2
            : 1;
    final col = direction == 'left'
        ? 0
        : direction == 'right'
            ? 2
            : 1;
    return Container(
      width: 214,
      height: 214,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFBFE9FF), Color(0xFFE8F7E4)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Column(
        children: [
          for (var r = 0; r < 3; r++)
            Expanded(
              child: Row(
                children: [
                  for (var c = 0; c < 3; c++)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: r == row && c == col
                              ? Colors.white.withValues(alpha: 0.85)
                              : Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: r == 1 && c == 1
                                ? const Color(0xFF90CAF9)
                                : Colors.white.withValues(alpha: 0.55),
                            width: r == 1 && c == 1 ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            r == 1 && c == 1
                                ? referenceEmoji
                                : r == row && c == col
                                    ? objectEmoji
                                    : '',
                            style: const TextStyle(fontSize: 44, height: 1.0),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}