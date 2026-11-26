import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../app_info.dart';
import '../content/islands.dart';
import '../models.dart';
import '../screens/island.dart';
import '../screens/parent.dart';
import '../screens/stickers.dart';
import '../speech.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/mascot.dart';

/// 首页：3D 渲染的森林小路。
///
/// 六座小岛是六颗"掉"在小路上的橡果，沿着小路一路往里散落。
/// 点哪一颗，小松鼠就伸手把那一颗抱进怀里，然后镜头跟着它往前走。
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// 一颗橡果在屏幕上的位置、宽度和歪倒的角度。
class _Spot {
  final double x;
  final double y;
  final double w;
  final double rot;
  const _Spot(this.x, this.y, this.w, this.rot);
}

/// 由近及远：橡果顺着小路散落，左右歪一点，越远越小。
const List<_Spot> _spots = [
  _Spot(0.508, 0.898, 0.152, -0.13),
  _Spot(0.348, 0.812, 0.139, 0.12),
  _Spot(0.482, 0.728, 0.127, -0.09),
  _Spot(0.356, 0.653, 0.116, 0.10),
  _Spot(0.468, 0.588, 0.105, -0.07),
  _Spot(0.368, 0.526, 0.095, 0.07),
];

/// 捡橡果的小松鼠（站在小路左边的草地上）。
const double _squirrelX = 0.170;
const double _squirrelY = 0.845;
const double _squirrelW = 0.118;

/// 另外两个看热闹的小动物。
class _Critter {
  final String asset;
  final double x;
  final double y;
  final double w;
  final double phase;
  const _Critter(this.asset, this.x, this.y, this.w, this.phase);
}

const List<_Critter> _critters = [
  _Critter('assets/animals/rabbit.png', 0.688, 0.668, 0.092, 0.78),
  _Critter('assets/animals/fox.png', 0.852, 0.905, 0.140, 0.30),
];

const double _acornAspect = 324 / 420;

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ProgressStore _store = ProgressStore();

  /// 相机慢慢往里走
  late final AnimationController _walk;

  /// 走路的步子（小动物跟着这个节奏蹦）
  late final AnimationController _step;

  /// 当前橡果的呼吸
  late final AnimationController _pulse;

  /// 小松鼠伸手抱起橡果
  late final AnimationController _pickup;

  /// 点完橡果镜头往前冲
  late final AnimationController _dash;

  int _picked = -1;
  Alignment _dashTarget = const Alignment(0, 0);

  @override
  void initState() {
    super.initState();
    _walk = AnimationController(vsync: this, duration: const Duration(seconds: 7))..repeat(reverse: true);
    _step = AnimationController(vsync: this, duration: const Duration(milliseconds: 1150))..repeat();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _pickup = AnimationController(vsync: this, duration: const Duration(milliseconds: 720));
    _dash = AnimationController(vsync: this, duration: const Duration(milliseconds: 340));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Speech.warmup();
      if (!mounted) return;
      Speech.welcome();
    });
  }

  @override
  void dispose() {
    _walk.dispose();
    _step.dispose();
    _pulse.dispose();
    _pickup.dispose();
    _dash.dispose();
    super.dispose();
  }

  void _openParent() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ParentScreen()));
  }

  void _openStickers() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StickersScreen()));
  }

  Future<void> _openIsland(IslandDef island, int index, _Spot spot) async {
    if (_pickup.isAnimating || _dash.isAnimating) return;

    if (!_store.islandUnlocked(island.id)) {
      Speech.say('先走完前面的小岛，这颗橡果才会掉下来哦');
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            backgroundColor: Palette.woodMid,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.fromLTRB(30, 0, 30, 90),
            content: Text(
              '先走完前面的小岛，这颗橡果才会掉下来哦',
              textAlign: TextAlign.center,
              style: TextStyle(color: Palette.woodInk, fontWeight: FontWeight.w800),
            ),
          ),
        );
      return;
    }

    // 1. 小松鼠把橡果捡起来
    setState(() => _picked = index);
    await _pickup.forward(from: 0);
    if (!mounted) return;

    // 2. 镜头朝那个方向走进去
    _dashTarget = Alignment(spot.x * 2 - 1, spot.y * 2 - 1);
    await _dash.forward(from: 0);
    if (!mounted) return;

    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (context, animation, secondary) => IslandScreen(island: island),
        transitionsBuilder: (context, animation, secondary, child) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
    if (!mounted) return;
    _pickup.value = 0;
    _dash.value = 0;
    setState(() => _picked = -1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.forestMid,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          return Stack(
            fit: StackFit.expand,
            children: [
              RepaintBoundary(
                child: AnimatedBuilder(
                  animation: Listenable.merge([_walk, _step, _dash]),
                  builder: (context, child) {
                    final t = _step.value;
                    final bob = math.sin(t * 2 * math.pi) * 3.2;
                    final sway = math.sin(t * math.pi) * 1.8;
                    final zoom = 1.0 +
                        0.078 * Curves.easeInOut.transform(_walk.value) +
                        0.30 * Curves.easeIn.transform(_dash.value);
                    return Transform.translate(
                      offset: Offset(sway, bob),
                      child: Transform.scale(
                        scale: zoom,
                        alignment: _dash.value > 0 ? _dashTarget : const Alignment(0, -0.35),
                        child: child,
                      ),
                    );
                  },
                  child: _scene(w, h),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    _SignBoard(
                      title: AppInfo.name,
                      subtitle: '沿着小路捡橡果',
                      stars: _store.totalStars,
                      onLongPressSettings: _openParent,
                    ),
                    const Spacer(),
                    _StickerBar(stickers: _store.stickerCount, onTap: _openStickers),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _scene(double w, double h) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        final currentIndex = islands.indexWhere((i) => _store.islandUnlocked(i.id) && !_store.islandCleared(i.id));
        return Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/home_bg.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                filterQuality: FilterQuality.medium,
              ),
            ),
            for (var i = 0; i < islands.length && i < _spots.length; i++)
              _acornView(
                island: islands[i],
                index: i,
                spot: _spots[i],
                cleared: _store.islandCleared(islands[i].id),
                locked: !_store.islandUnlocked(islands[i].id),
                current: i == currentIndex,
                w: w,
                h: h,
              ),
            _squirrelView(w, h),
            for (final critter in _critters) _critterView(critter, w, h),
            if (currentIndex >= 0)
              _currentPlaque(
                island: islands[currentIndex],
                spot: _spots[currentIndex.clamp(0, _spots.length - 1)],
                w: w,
                h: h,
              ),
          ],
        );
      },
    );
  }

  Widget _acornView({
    required IslandDef island,
    required int index,
    required _Spot spot,
    required bool cleared,
    required bool locked,
    required bool current,
    required double w,
    required double h,
  }) {
    final width = spot.w * w;
    final height = width / _acornAspect;
    final home = Offset(spot.x * w, spot.y * h);
    final hit = math.max(width * 1.35, 56.0);

    return Positioned(
      left: home.dx - hit / 2,
      top: home.dy - hit / 2,
      width: hit,
      height: hit,
      child: GestureDetector(
        key: ValueKey('acorn-$index'),
        behavior: HitTestBehavior.opaque,
        onTap: () => _openIsland(island, index, spot),
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_pulse, _pickup]),
            builder: (context, _) {
              final picked = _picked == index;
              final t = picked ? Curves.easeInOut.transform(_pickup.value) : 0.0;

              // 被抱走的时候：沿着一条弧线飞进小松鼠怀里，越飞越小
              final targetX = _squirrelX * w;
              final targetY = (_squirrelY - 0.045) * h;
              final x = home.dx + (targetX - home.dx) * t;
              final y = home.dy + (targetY - home.dy) * t - math.sin(t * math.pi) * h * 0.10;
              final scale = 1.0 - 0.55 * t;

              final breathe = current ? 1.0 + 0.05 * _pulse.value : 1.0;

              return Transform.translate(
                offset: Offset(x - home.dx, y - home.dy),
                child: Transform.scale(
                  scale: scale * breathe,
                  alignment: Alignment.bottomCenter,
                  child: Opacity(
                    // 飞向松鼠的橡果到最后一小段才淡出，别一路半透明
                    opacity: picked
                        ? (t < 0.72 ? 1.0 : (1.0 - (t - 0.72) / 0.28).clamp(0.0, 1.0))
                        : 1.0,
                    child: _Acorn(
                      width: width,
                      height: height,
                      rotation: spot.rot,
                      locked: locked,
                      cleared: cleared,
                      glow: current,
                      glowT: _pulse.value,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _squirrelView(double w, double h) {
    final width = _squirrelW * w;
    final height = width / 0.66;
    return Positioned(
      left: _squirrelX * w - width / 2,
      top: _squirrelY * h - height,
      width: width,
      height: height,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: Listenable.merge([_pickup, _step]),
          builder: (context, _) {
            final carrying = _picked >= 0;
            final t = _pickup.value;
            // 捡到以后高兴地蹦一下
            final happyLift = carrying ? math.sin(t * math.pi) * height * 0.22 : 0.0;
            // 平时跟着走路的节奏轻轻晃
            final idle = carrying ? 0.0 : math.sin((_step.value + 0.52) % 1.0 * math.pi) * height * 0.03;

            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                  bottom: 0,
                  child: Opacity(
                    opacity: 0.30 * (1 - (happyLift / (height * 0.3)).clamp(0.0, 0.8)),
                    child: Container(
                      width: width * 0.78,
                      height: height * 0.13,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [Color(0xFF241708), Color(0x00241708)], stops: [0.35, 1.0]),
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, -happyLift - idle),
                  child: Image.asset(
                    carrying ? 'assets/animals/squirrel_carry.png' : 'assets/animals/squirrel.png',
                    width: width,
                    height: height,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _critterView(_Critter critter, double w, double h) {
    final width = critter.w * w;
    final height = width / 0.66;
    return Positioned(
      left: critter.x * w - width / 2,
      top: critter.y * h - height,
      width: width,
      height: height,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _step,
          builder: (context, _) {
            final t = (_step.value + critter.phase) % 1.0;
            final hop = t < 0.45 ? math.sin(t / 0.45 * math.pi) : 0.0;
            final lift = hop * height * 0.26;
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                  bottom: 0,
                  child: Opacity(
                    opacity: 0.28 * (1 - hop * 0.7),
                    child: Container(
                      width: width * 0.75,
                      height: height * 0.14,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [Color(0xFF241708), Color(0x00241708)], stops: [0.35, 1.0]),
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, -lift),
                  child: Transform.scale(
                    scaleX: 1.0 + 0.06 * hop,
                    scaleY: 1.0 - 0.08 * hop,
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      critter.asset,
                      width: width,
                      height: height,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _currentPlaque({required IslandDef island, required _Spot spot, required double w, required double h}) {
    final width = spot.w * w;
    final left = spot.x * w + width * 0.55;
    final top = spot.y * h - width * 0.95;
    final maxWidth = (w - left - 10).clamp(60.0, 150.0);
    return Positioned(
      left: left,
      top: top,
      width: maxWidth,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, -2 + 2 * _pulse.value),
            child: child,
          ),
          child: _Plaque(emoji: island.emoji, name: island.name),
        ),
      ),
    );
  }
}

/// 一颗橡果：底下有接地阴影，够亮的还会有一圈暖光。
class _Acorn extends StatelessWidget {
  final double width;
  final double height;
  final double rotation;
  final bool locked;
  final bool cleared;
  final bool glow;
  final double glowT;

  const _Acorn({
    required this.width,
    required this.height,
    required this.rotation,
    required this.locked,
    required this.cleared,
    required this.glow,
    required this.glowT,
  });

  @override
  Widget build(BuildContext context) {
    Widget body = Image.asset(
      'assets/animals/acorn.png',
      width: width,
      height: height,
      filterQuality: FilterQuality.medium,
    );
    if (locked) {
      // 用保 alpha 的灰度矩阵，别用 BlendMode.saturation（那个会把透明区域也涂成灰块）
      body = ColorFiltered(
        // 只压暗、不褪色，锁着的橡果还是一颗暖棕色的橡果
        colorFilter: const ColorFilter.matrix(<double>[
          0.86, 0, 0, 0, 0,
          0, 0.83, 0, 0, 0,
          0, 0, 0.80, 0, 0,
          0, 0, 0, 1, 0,
        ]),
        child: body,
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // 接地阴影
        Positioned(
          bottom: height * 0.01,
          child: Container(
            width: width * 1.02,
            height: width * 0.30,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [Color(0x77271A0B), Color(0x00271A0B)], stops: [0.05, 1.0]),
            ),
          ),
        ),
        if (glow)
          Positioned(
            bottom: height * 0.06,
            child: Container(
              width: width * (1.35 + 0.1 * glowT),
              height: height * (0.72 + 0.05 * glowT),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color.fromRGBO(255, 236, 170, 0.55 - 0.18 * glowT), const Color(0x00FFECAA)],
                  stops: const [0.2, 1.0],
                ),
              ),
            ),
          ),
        Transform.rotate(angle: rotation, alignment: Alignment.bottomCenter, child: body),
        if (cleared)
          Positioned(
            right: -width * 0.06,
            top: height * 0.12,
            child: Container(
              width: width * 0.42,
              height: width * 0.42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4CAF50),
                border: Border.all(color: Colors.white, width: width * 0.05),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: width * 0.1, offset: Offset(0, width * 0.04)),
                ],
              ),
              child: Icon(Icons.check_rounded, color: Colors.white, size: width * 0.26),
            ),
          ),
        if (locked)
          Positioned(
            right: -width * 0.05,
            top: height * 0.10,
            child: Container(
              width: width * 0.42,
              height: width * 0.42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF5E5E5E),
                border: Border.all(color: const Color(0xFFF0ECE2), width: width * 0.05),
              ),
              child: Icon(Icons.lock_rounded, color: Colors.white, size: width * 0.24),
            ),
          ),
      ],
    );
  }
}

/// 当前这一岛的木牌：图标 + 名字。
class _Plaque extends StatelessWidget {
  final String emoji;
  final String name;
  const _Plaque({required this.emoji, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 5, 10, 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Palette.woodLight, Palette.woodMid, Palette.woodDark],
          stops: [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE9C9), width: 2.4),
        boxShadow: [
          BoxShadow(color: const Color(0x55291B0E), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 15, height: 1.0)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                height: 1.1,
                fontWeight: FontWeight.w900,
                color: Palette.woodInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 顶上挂着的木牌：应用名 + 星星总数 + 家长设置入口。
class _SignBoard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int stars;
  final VoidCallback onLongPressSettings;

  const _SignBoard({
    required this.title,
    required this.subtitle,
    required this.stars,
    required this.onLongPressSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 84,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Palette.woodLight, Palette.woodMid, Palette.woodDark],
                  stops: [0.0, 0.62, 1.0],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFFFE9C9), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x66291B0E),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: CustomPaint(
                painter: const _WoodPainter(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 10, 6),
                  child: Row(
                    children: [
                      const FoxBuddy(size: 48),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                title,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 26,
                                  height: 1.1,
                                  fontWeight: FontWeight.w900,
                                  color: Palette.woodInk,
                                  shadows: [
                                    Shadow(color: Color(0x66FFF3D6), blurRadius: 3, offset: Offset(0, 2)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 1),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                subtitle,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Palette.woodInk.withValues(alpha: 0.78),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      _StarChip(stars: stars),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onLongPress: onLongPressSettings,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Palette.woodLight, Palette.woodMid],
                ),
                border: Border.all(color: const Color(0xFFFFE9C9), width: 3),
                boxShadow: [
                  BoxShadow(color: const Color(0x55291B0E), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: const Icon(Icons.settings_rounded, color: Palette.woodInk, size: 26),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarChip extends StatelessWidget {
  final int stars;
  const _StarChip({required this.stars});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Palette.cream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Palette.woodDark.withValues(alpha: 0.5), width: 1.6),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.14), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 20),
          const SizedBox(width: 3),
          Text(
            '$stars',
            style: const TextStyle(
              fontSize: 15,
              height: 1.1,
              fontWeight: FontWeight.w900,
              color: Palette.woodInk,
            ),
          ),
        ],
      ),
    );
  }
}

/// 底部木条：贴纸册入口。
class _StickerBar extends StatelessWidget {
  final int stickers;
  final VoidCallback onTap;
  const _StickerBar({required this.stickers, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 4, 40, 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Palette.woodLight, Palette.woodMid],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFE9C9), width: 2.5),
            boxShadow: [
              BoxShadow(color: const Color(0x55291B0E), blurRadius: 12, offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🏅', style: TextStyle(fontSize: 22, height: 1.0)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '贴纸册',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                    color: Palette.woodInk,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '已收集 $stickers/24 张',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                    color: Palette.woodInk.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 木纹 + 四角钉子。
class _WoodPainter extends CustomPainter {
  const _WoodPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final grain = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = Palette.woodInk.withValues(alpha: 0.16);
    for (var i = 0; i < 4; i++) {
      final y = size.height * (0.18 + i * 0.21);
      final path = Path()
        ..moveTo(size.width * 0.05, y)
        ..quadraticBezierTo(size.width * 0.5, y + (i.isEven ? 3 : -3), size.width * 0.95, y);
      canvas.drawPath(path, grain);
    }

    final nail = Paint()..color = const Color(0xFF7A5230);
    final shine = Paint()..color = Colors.white.withValues(alpha: 0.45);
    for (final p in [
      Offset(11, 11),
      Offset(size.width - 11, 11),
      Offset(11, size.height - 11),
      Offset(size.width - 11, size.height - 11),
    ]) {
      canvas.drawCircle(p, 3.4, nail);
      canvas.drawCircle(p + const Offset(-0.8, -0.8), 1.3, shine);
    }
  }

  @override
  bool shouldRepaint(covariant _WoodPainter oldDelegate) => false;
}
