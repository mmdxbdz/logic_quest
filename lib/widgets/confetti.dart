import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 庆祝彩纸：一次性飘落
class Confetti extends StatefulWidget {
  final int count;
  const Confetti({super.key, this.count = 60});

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<_Piece> _pieces;

  @override
  void initState() {
    super.initState();
    final rnd = math.Random();
    const colors = [
      Color(0xFFFF8A80),
      Color(0xFFFFD54F),
      Color(0xFF80CBC4),
      Color(0xFF81D4FA),
      Color(0xFFB39DDB),
      Color(0xFF9CCC65),
    ];
    _pieces = [
      for (var i = 0; i < widget.count; i++)
        _Piece(
          x: rnd.nextDouble(),
          y: -rnd.nextDouble() * 0.5,
          speed: 0.5 + rnd.nextDouble() * 0.7,
          sway: rnd.nextDouble() * 2 - 1,
          size: 6 + rnd.nextDouble() * 7,
          color: colors[rnd.nextInt(colors.length)],
          round: rnd.nextBool(),
          phase: rnd.nextDouble() * math.pi * 2,
        ),
    ];
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _ConfettiPainter(_pieces, _c.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _Piece {
  final double x;
  final double y;
  final double speed;
  final double sway;
  final double size;
  final Color color;
  final bool round;
  final double phase;
  const _Piece({
    required this.x,
    required this.y,
    required this.speed,
    required this.sway,
    required this.size,
    required this.color,
    required this.round,
    required this.phase,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Piece> pieces;
  final double t;
  _ConfettiPainter(this.pieces, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    for (final p in pieces) {
      final y = (p.y + t * p.speed * 1.25) * size.height;
      if (y < -40 || y > size.height + 40) continue;
      final x = (p.x + math.sin(t * 6 + p.phase) * 0.035 * p.sway) * size.width;
      final fade = (1 - t).clamp(0.0, 1.0);
      final paint = Paint()..color = p.color.withValues(alpha: 0.85 * fade);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * 5 + p.phase);
      if (p.round) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.55),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => oldDelegate.t != t;
}
