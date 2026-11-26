import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../gen/levels.dart';
import '../models.dart';
import '../screens/result.dart';
import '../soundfx.dart';
import '../speech.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/mascot.dart';
import '../widgets/puzzle_views.dart';

class ChoiceGameScreen extends StatefulWidget {
  final IslandDef island;
  final int level;
  const ChoiceGameScreen({super.key, required this.island, required this.level});

  @override
  State<ChoiceGameScreen> createState() => _ChoiceGameScreenState();
}

class _ChoiceGameScreenState extends State<ChoiceGameScreen> {
  late final List<Puzzle> _puzzles;
  int _index = 0;
  int _mistakes = 0;
  int _attempts = 0;
  bool _solved = false;
  bool _busy = false;
  bool _finishing = false;
  Set<int> _selected = {};
  Set<int> _revealed = {};
  Set<int> _wrong = {};
  Timer? _timer;

  Puzzle get _current => _puzzles[_index];

  @override
  void initState() {
    super.initState();
    _puzzles = buildPuzzles(widget.island.kind, widget.level, Random());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Speech.say(_current.prompt);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Set<int> _correctSet(Puzzle p) {
    if (p is PatternPuzzle) return {p.correct};
    if (p is ClassifyPuzzle) return p.correct;
    if (p is PositionPuzzle) return {p.correct};
    if (p is CountPuzzle) return {p.correct};
    if (p is ComparePuzzle) return {p.correctSide};
    if (p is SequencePuzzle) return {p.correct};
    if (p is EqualPuzzle) return {p.correct};
    if (p is ShadowPuzzle) return {p.correct};
    if (p is TilePuzzle) return {p.correct};
    return const {};
  }

  void _onTap(int i) {
    if (_busy || _solved) return;
    final p = _current;
    final correct = _correctSet(p);
    final multi = p is ClassifyPuzzle && p.pair;

    if (multi) {
      final next = {..._selected};
      if (next.contains(i)) {
        next.remove(i);
      } else {
        next.add(i);
      }
      setState(() {
        _selected = next;
        _wrong = {};
      });
      if (next.length == correct.length) {
        if (setEquals(next, correct)) {
          _onCorrect();
        } else {
          _onWrong(next);
        }
      }
      return;
    }

    if (correct.contains(i)) {
      _onCorrect();
    } else {
      _onWrong({i});
    }
  }

  void _onCorrect() {
    SoundFx.ding();
    Speech.cheer();
    setState(() {
      _solved = true;
      _busy = true;
      _revealed = _correctSet(_current);
      _wrong = {};
    });
    _timer = Timer(const Duration(milliseconds: 950), _advance);
  }

  void _onWrong(Set<int> chosen) {
    _mistakes++;
    _attempts++;
    SoundFx.boop();
    if (_attempts >= 2) {
      setState(() {
        _wrong = {};
        _revealed = _correctSet(_current);
        _busy = true;
        _selected = {};
      });
      Speech.say('看，是这样哦。');
      _timer = Timer(const Duration(milliseconds: 1700), _advance);
    } else {
      setState(() {
        _wrong = chosen;
        _selected = {};
      });
      Speech.encourage();
      _timer = Timer(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() => _wrong = {});
      });
    }
  }

  void _advance() {
    if (!mounted) return;
    if (_index + 1 >= _puzzles.length) {
      _finish();
      return;
    }
    setState(() {
      _index++;
      _selected = {};
      _revealed = {};
      _wrong = {};
      _solved = false;
      _busy = false;
      _attempts = 0;
    });
    Speech.say(_current.prompt);
  }

  Future<void> _finish() async {
    if (_finishing) return;
    _finishing = true;
    final stars = _mistakes <= 1 ? 3 : (_mistakes <= 3 ? 2 : 1);
    final newStickers =
        await ProgressStore().recordLevel(widget.island.id, widget.level, stars);
    if (!mounted) return;
    SoundFx.tada();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          island: widget.island,
          level: widget.level,
          stars: stars,
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
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
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
                      '${widget.island.emoji} ${widget.island.name} · 第 ${widget.level} 关',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Palette.ink,
                      ),
                    ),
                  ),
                  _Dots(total: _puzzles.length, current: _index),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 6, 4, 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    FoxBuddy(size: 40, cheer: _solved),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _current.prompt,
                        style: const TextStyle(
                          fontSize: 17,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          color: Palette.ink,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Speech.say(_current.prompt),
                      icon: const Icon(Icons.volume_up_rounded, color: Palette.inkSoft),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: PuzzleView(
                  puzzle: _current,
                  accent: widget.island.color,
                  selected: _selected,
                  revealed: _revealed,
                  wrong: _wrong,
                  locked: _busy || _solved,
                  onTap: _onTap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int total;
  final int current;
  const _Dots({required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < total; i++)
          Container(
            width: i == current ? 18 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: i < current
                  ? Palette.good
                  : (i == current ? Palette.tangerine : const Color(0xFFDDE3E8)),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
