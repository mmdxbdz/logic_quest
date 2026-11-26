import 'package:flutter_test/flutter_test.dart';
import 'package:logic_quest/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final store = ProgressStore();
    await store.load();
    await store.resetAll();
    await store.setVoice(true);
  });

  test('记录星星、解锁下一关、累计贴纸', () async {
    final store = ProgressStore();
    expect(store.starsOf('pattern', 1), 0);
    expect(store.isLevelUnlocked('pattern', 1), isTrue);
    expect(store.isLevelUnlocked('pattern', 2), isFalse);

    final newStickers = await store.recordLevel('pattern', 1, 2);
    expect(store.starsOf('pattern', 1), 2);
    expect(store.totalStars, 2);
    expect(store.stickerCount, 1);
    expect(newStickers, [0]);
    expect(store.isLevelUnlocked('pattern', 2), isTrue);
    expect(store.isLevelUnlocked('pattern', 3), isFalse);
  });

  test('重玩只记录更高的星星', () async {
    final store = ProgressStore();
    await store.recordLevel('pattern', 1, 3);
    await store.recordLevel('pattern', 1, 1);
    expect(store.starsOf('pattern', 1), 3);
    await store.recordLevel('maze', 1, 9);
    expect(store.starsOf('maze', 1), 3);
  });

  test('语音开关与重置', () async {
    final store = ProgressStore();
    await store.setVoice(false);
    expect(store.voiceOn, isFalse);
    await store.setVoice(true);
    expect(store.voiceOn, isTrue);

    await store.recordLevel('number', 1, 3);
    await store.resetAll();
    expect(store.totalStars, 0);
    expect(store.starsOf('number', 1), 0);
    expect(store.stickerCount, 0);
  });

  test('小岛按顺序解锁：走完前一个才开下一个', () async {
    final store = ProgressStore();
    expect(store.islandUnlocked('pattern'), isTrue);
    expect(store.islandUnlocked('classify'), isFalse);
    expect(store.currentIslandId, 'pattern');

    // 走完前 7 关还不够
    for (var lv = 1; lv <= 7; lv++) {
      await store.recordLevel('pattern', lv, 1);
    }
    expect(store.islandCleared('pattern'), isFalse);
    expect(store.islandUnlocked('classify'), isFalse);

    await store.recordLevel('pattern', 8, 1);
    expect(store.islandCleared('pattern'), isTrue);
    expect(store.islandUnlocked('classify'), isTrue);
    expect(store.currentIslandId, 'classify');
  });

  test('存档可以重新载入', () async {
    final store = ProgressStore();
    await store.recordLevel('shape', 1, 3);
    await store.setVoice(false);

    final reloaded = ProgressStore();
    await reloaded.load();
    expect(reloaded.starsOf('shape', 1), 3);
    expect(reloaded.voiceOn, isFalse);
  });
}
