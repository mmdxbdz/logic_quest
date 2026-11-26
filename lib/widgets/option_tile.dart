import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';

IconData arrowIcon(String arrow) => switch (arrow) {
      'up' => Icons.arrow_upward_rounded,
      'down' => Icons.arrow_downward_rounded,
      'left' => Icons.arrow_back_rounded,
      'right' => Icons.arrow_forward_rounded,
      _ => Icons.arrow_upward_rounded,
    };

/// 一张可点的答案卡片
class OptionTile extends StatelessWidget {
  final OptionSpec spec;
  final double size;
  final bool selected;
  final bool revealed; // 正确答案
  final bool wrong; // 刚点错
  final bool enabled;
  final Color accent;
  final VoidCallback? onTap;

  const OptionTile({
    super.key,
    required this.spec,
    required this.accent,
    this.size = 82,
    this.selected = false,
    this.revealed = false,
    this.wrong = false,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = revealed
        ? Palette.good
        : wrong
            ? Palette.bad
            : selected
                ? accent
                : Colors.white.withValues(alpha: 0.9);
    final bg = revealed
        ? const Color(0xFFE8F5E9)
        : wrong
            ? const Color(0xFFFFEBEE)
            : Colors.white.withValues(alpha: enabled ? 0.96 : 0.55);
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: AnimatedScale(
          scale: selected && !revealed ? 1.04 : 1.0,
          duration: const Duration(milliseconds: 140),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: size,
            height: size,
            padding: EdgeInsets.all(size * 0.1),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(size * 0.26),
              border: Border.all(
                color: borderColor,
                width: revealed || selected || wrong ? 3.5 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: enabled ? 0.07 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(child: _content(size)),
          ),
        ),
      ),
    );
  }

  Widget _content(double s) {
    final group = spec.group;
    if (group != null) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 2,
          runSpacing: 2,
          children: [
            for (final e in group) Text(e, style: TextStyle(fontSize: s * 0.24, height: 1.0)),
          ],
        ),
      );
    }
    final arrow = spec.arrow;
    if (arrow != null) {
      return Icon(arrowIcon(arrow), size: s * 0.56, color: accent);
    }
    if (spec.shape != null) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          spec.shape!,
          style: TextStyle(
            fontSize: s * 0.62,
            height: 1.0,
            color: spec.color,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                color: (spec.color ?? Colors.black).withValues(alpha: 0.28),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      );
    }
    if (spec.text != null) {
      return Text(
        spec.text!,
        style: TextStyle(
          fontSize: s * 0.46,
          height: 1.0,
          fontWeight: FontWeight.w800,
          color: Palette.ink,
        ),
      );
    }
    if (spec.emoji != null) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(spec.emoji!, style: TextStyle(fontSize: s * 0.54, height: 1.0)),
      );
    }
    if (spec.color != null) {
      return Container(
        decoration: BoxDecoration(color: spec.color, shape: BoxShape.circle),
      );
    }
    return const SizedBox.shrink();
  }
}

/// 一排答案卡片
class OptionGrid extends StatelessWidget {
  final List<OptionSpec> options;
  final Set<int> selected;
  final Set<int> revealed;
  final Set<int> wrong;
  final bool enabled;
  final Color accent;
  final double size;
  final ValueChanged<int>? onTap;

  const OptionGrid({
    super.key,
    required this.options,
    required this.accent,
    this.selected = const {},
    this.revealed = const {},
    this.wrong = const {},
    this.enabled = true,
    this.size = 82,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        for (var i = 0; i < options.length; i++)
          OptionTile(
            spec: options[i],
            size: size,
            accent: accent,
            selected: selected.contains(i),
            revealed: revealed.contains(i),
            wrong: wrong.contains(i),
            enabled: enabled,
            onTap: onTap == null ? null : () => onTap!(i),
          ),
      ],
    );
  }
}
