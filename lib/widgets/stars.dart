import 'package:flutter/material.dart';
import '../theme.dart';

class StarBar extends StatelessWidget {
  final int stars;
  final double size;
  const StarBar({super.key, required this.stars, this.size = 26});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size * 0.06),
            child: Icon(
              i < stars ? Icons.star_rounded : Icons.star_rounded,
              size: size,
              color: i < stars ? const Color(0xFFFFB300) : const Color(0xFFE0E5E9),
              shadows: i < stars
                  ? const [Shadow(color: Color(0x33FFB300), blurRadius: 8)]
                  : null,
            ),
          ),
      ],
    );
  }
}

/// 大号展示三颗星（结果页）
class BigStars extends StatelessWidget {
  final int stars;
  const BigStars({super.key, required this.stars});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < 3; i++)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.2, end: i < stars ? 1.0 : 0.55),
            duration: Duration(milliseconds: 500 + i * 250),
            curve: Curves.elasticOut,
            builder: (context, v, child) => Transform.scale(scale: v, child: child),
            child: Icon(
              Icons.star_rounded,
              size: 64,
              color: i < stars ? const Color(0xFFFFC107) : const Color(0xFFDDE3E7),
            ),
          ),
      ],
    );
  }
}

class TotalStarBadge extends StatelessWidget {
  final int stars;
  const TotalStarBadge({super.key, required this.stars});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 24),
          const SizedBox(width: 6),
          Text(
            '$stars',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Palette.ink,
            ),
          ),
        ],
      ),
    );
  }
}
