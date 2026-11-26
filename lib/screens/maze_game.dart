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

class MazeGameScreen extends StatefulWidget {
  final IslandDef island;
  final int level;
  const MazeGameScreen({super.key, required this.island, required this.level});

  @override
  State<MazeGameScreen> createState() => _MazeGameScreenState();
}

class _MazeGameScreenState extends State<MazeGameScreen> {
  late final MazePuzzle _maze;
  late int _player;
  int _steps = 0;
  int _bumps = 0;
  bool _won = false;
  bool _finishing = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _maze = buildPuzzles(widget.island.kind, widget.level, Random()).first
        as MazePuzzle;
    _player = _maze.start;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Speech.say('帮小兔子走到胡萝卜那里吧。用下面的箭头，带它走一走。');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _reset() {
    if (_won) return;
    setState(() {
      _player = _maze.start;
      _steps = 0;
      _bumps = 0;
    });
  }

  void _move(int dx, int dy) {
    if (_won || _finishing) return;
    if (!_maze.canMove(_player, dx, dy)) {
      setState(() => _bumps++);
      SoundFx.boop();
      return;
    }
    setState(() {
      _player = _maze.move(_player, dx, dy);
      _steps++;
    });
    SoundFx.pop();
    if (_player == _maze.goal) {
      setState(() => _won = true);
      _timer = Timer(const Duration(milliseconds: 700), _finish);
    }
  }

  int get _stars {
    if (_bumps == 0 && _steps <= _maze.optimal + 3) return 3;
    if (_bumps <= 2) return 2;
    return 1;
  }

  Future<void> _finish() async {
    if (_finishing) return;
    _finishing = true;
    SoundFx.tada();
    Speech.celebrate();
    final newStickers =
        await ProgressStore().recordLevel(widget.island.id, widget.level, _stars);
    if (!mounted) return;
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
                      '${widget.island.emoji} 小迷宫 · 第 ${widget.level} 关',
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
                      '步数 $_steps',
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
              FoxBubble(
                text: _won ? '找到胡萝卜啦！' : '帮小兔子走到胡萝卜那里吧！',
                foxSize: 42,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _Board(
                        maze: _maze,
                        player: _player,
                        won: _won,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PadButton(
                    icon: Icons.arrow_upward_rounded,
                    onTap: () => _move(0, -1),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PadButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => _move(-1, 0),
                  ),
                  const SizedBox(width: 54),
                  _PadButton(
                    icon: Icons.arrow_forward_rounded,
                    onTap: () => _move(1, 0),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PadButton(
                    icon: Icons.arrow_downward_rounded,
                    onTap: () => _move(0, 1),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('重新走一遍'),
                style: TextButton.styleFrom(foregroundColor: Palette.inkSoft),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Board extends StatelessWidget {
  final MazePuzzle maze;
  final int player;
  final bool won;
  const _Board({required this.maze, required this.player, required this.won});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var y = 0; y < maze.rows; y++)
          Expanded(
            child: Row(
              children: [
                for (var x = 0; x < maze.cols; x++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(2.5),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: maze.isWall(y * maze.cols + x)
                              ? const Color(0xFF81C784)
                              : const Color(0xFFFFF6E0),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.8),
                            width: 1.5,
                          ),
                        ),
                        child: Center(child: _cell(y * maze.cols + x)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _cell(int index) {
    if (maze.isWall(index)) {
      return const Text('🌿', style: TextStyle(fontSize: 16, height: 1.0));
    }
    if (index == maze.goal) {
      return const FittedBox(
        fit: BoxFit.scaleDown,
        child: Text('🥕', style: TextStyle(fontSize: 34, height: 1.0)),
      );
    }
    if (index == player) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          won ? '🎉' : '🐰',
          style: const TextStyle(fontSize: 34, height: 1.0),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _PadButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _PadButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 2,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Icon(icon, size: 32, color: Palette.tangerine),
          ),
        ),
      ),
    );
  }
}
