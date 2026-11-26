import 'package:flutter/material.dart';

/// 思维小岛配色：云杉森林、木牌、彩色踏石、奶油卡纸。
class Palette {
  // 森林场景（黏土质感）
  static const Color forestSky = Color(0xFFEAF6DF);
  static const Color forestHaze = Color(0xFFCFEAB4);
  static const Color forestMid = Color(0xFFA8D886);
  static const Color forestDeep = Color(0xFF74BD58);
  static const Color forestShade = Color(0xFF4F9A3C);

  // 踏石小路
  static const Color trailBase = Color(0xFFF4E8CB);
  static const Color trailEdge = Color(0xFFD8C199);

  // 木牌
  static const Color woodLight = Color(0xFFE7BC84);
  static const Color woodMid = Color(0xFFD29A5E);
  static const Color woodDark = Color(0xFFA96C39);
  static const Color woodInk = Color(0xFF6B4123);


  static const Color skyTop = Color(0xFFB3E5FC);
  static const Color skyMid = Color(0xFF81D4FA);
  static const Color seaDeep = Color(0xFF29B6F6);
  static const Color seaLight = Color(0xFFB3E5FC);

  static const Color ink = Color(0xFF35505F);
  static const Color inkSoft = Color(0xFF6B8797);
  static const Color cream = Color(0xFFFFFBF2);
  static const Color card = Color(0xFFFFFDF8);

  static const Color coral = Color(0xFFFF8A80);
  static const Color mint = Color(0xFF80CBC4);
  static const Color skyBlue = Color(0xFF81D4FA);
  static const Color tangerine = Color(0xFFFFB74D);
  static const Color lilac = Color(0xFFB39DDB);
  static const Color leaf = Color(0xFF9CCC65);
  static const Color sun = Color(0xFFFFE082);

  static const Color good = Color(0xFF66BB6A);
  static const Color bad = Color(0xFFEF5350);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Palette.seaDeep,
    scaffoldBackgroundColor: Palette.cream,
    fontFamilyFallback: const ['Noto Sans SC', 'Microsoft YaHei', 'sans-serif'],
    splashFactory: NoSplash.splashFactory,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: Palette.ink,
      displayColor: Palette.ink,
    ),
  );
}
