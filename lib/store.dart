import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'content/islands.dart' show islands;

/// 本地进度：每关最佳星星、语音开关。全部存在手机里。
class ProgressStore extends ChangeNotifier {
  static const String _key = 'logic_quest_v1';
  static const int maxStarsPerLevel = 3;
  static const int levelsPerIsland = 8;

  static final ProgressStore _instance = ProgressStore._();
  factory ProgressStore() => _instance;
  ProgressStore._();

  /// 'pattern:3' -> 最佳星数 1..3
  final Map<String, int> _stars = {};
  bool voiceOn = true;
  bool loaded = false;

  int starsOf(String islandId, int level) => _stars['$islandId:$level'] ?? 0;

  int islandStars(String islandId) {
    var sum = 0;
    for (var lv = 1; lv <= levelsPerIsland; lv++) {
      sum += starsOf(islandId, lv);
    }
    return sum;
  }

  int get totalStars => _stars.values.fold(0, (a, b) => a + b);

  int get maxTotalStars => levelsPerIsland * maxStarsPerLevel * 6;

  /// 一共能收集 24 张贴纸，每 2 颗星解锁一张。
  int get stickerCount {
    final n = totalStars ~/ 2;
    return n.clamp(0, 24);
  }

  int get nextStickerStars {
    final next = (stickerCount + 1).clamp(1, 24);
    return next * 2;
  }

  bool isLevelUnlocked(String islandId, int level) =>
      level <= 1 || starsOf(islandId, level - 1) > 0;

  bool islandFinished(String islandId) => islandStars(islandId) >= levelsPerIsland * maxStarsPerLevel;

  /// 这个小岛的 8 关是不是都至少拿到一颗星（＝ 走完了）。
  bool islandCleared(String islandId) {
    for (var lv = 1; lv <= levelsPerIsland; lv++) {
      if (starsOf(islandId, lv) == 0) return false;
    }
    return true;
  }

  /// 六个小岛按顺序解锁：走完前一个，才开下一个。
  bool islandUnlocked(String islandId) {
    final idx = islands.indexWhere((i) => i.id == islandId);
    if (idx <= 0) return true;
    return islandCleared(islands[idx - 1].id);
  }

  /// 当前该玩的那一个（第一个解锁了但还没走完的）。
  String? get currentIslandId {
    for (final island in islands) {
      if (!islandUnlocked(island.id)) return null;
      if (!islandCleared(island.id)) return island.id;
    }
    return null;
  }

  Future<void> load() async {
    _stars.clear();
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString(_key);
      if (raw != null) {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        (j['stars'] as Map?)?.forEach((k, v) {
          final n = (v as num).toInt().clamp(0, maxStarsPerLevel);
          if (n > 0) _stars[k.toString()] = n;
        });
        voiceOn = j['voice'] as bool? ?? true;
      }
    } catch (_) {
      // 存档损坏时重新开始
    }
    loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(
        _key,
        jsonEncode({
          'stars': _stars,
          'voice': voiceOn,
        }),
      );
    } catch (_) {
      // 保存失败不打断游戏
    }
  }

  /// 记录一次通关结果，返回新解锁的贴纸序号列表。
  Future<List<int>> recordLevel(String islandId, int level, int stars) async {
    final key = '$islandId:$level';
    final before = stickerCount;
    final capped = stars.clamp(0, maxStarsPerLevel);
    if (capped > (_stars[key] ?? 0)) {
      _stars[key] = capped;
    }
    await _save();
    notifyListeners();
    final after = stickerCount;
    if (after > before) {
      return [for (var i = before; i < after; i++) i];
    }
    return const [];
  }

  Future<void> setVoice(bool on) async {
    voiceOn = on;
    await _save();
    notifyListeners();
  }

  Future<void> resetAll() async {
    _stars.clear();
    await _save();
    notifyListeners();
  }
}
