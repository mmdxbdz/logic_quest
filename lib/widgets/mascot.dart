import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

/// 小狐狸：轻轻跳动的吉祥物
class FoxBuddy extends StatefulWidget {
  final double size;
  final bool cheer;
  const FoxBuddy({super.key, this.size = 72, this.cheer = false});

  @override
  State<FoxBuddy> createState() => _FoxBuddyState();
}

class _FoxBuddyState extends State<FoxBuddy> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amp = widget.cheer ? 0.14 : 0.06;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value * 2 * math.pi;
        final scale = 1 + amp * math.sin(t);
        final dy = (widget.cheer ? 8 : 3) * math.sin(t);
        return Transform.translate(
          offset: Offset(0, -dy),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: Text(
        '🦊',
        style: TextStyle(fontSize: widget.size, height: 1.0),
      ),
    );
  }
}

/// 小狐狸说的话（气泡）
class FoxBubble extends StatelessWidget {
  final String text;
  final double foxSize;
  final Color? color;
  const FoxBubble({
    super.key,
    required this.text,
    this.foxSize = 44,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FoxBuddy(size: foxSize),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: color ?? Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.35,
                color: Palette.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
