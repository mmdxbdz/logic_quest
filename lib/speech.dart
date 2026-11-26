import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';
import 'store.dart';

/// 中文语音：读题、鼓励、庆祝。系统 TTS，离线可用。
class Speech {
  static FlutterTts? _tts;
  static bool _ready = false;
  static final Random _rnd = Random();

  static const List<String> _cheer = [
    '太棒了！',
    '答对啦！',
    '真聪明！',
    '好厉害呀！',
    '就是这样，你真棒！',
    '哇，你做到了！',
  ];

  static const List<String> _encourage = [
    '再试一试。',
    '差一点点，再来一次。',
    '没关系，再想一想。',
    '看看别的答案呢？',
    '别着急，慢慢来。',
  ];

  static const List<String> _celebrate = [
    '这一关闯过啦，真棒！',
    '哇，你拿到星星啦！',
    '太厉害了，我们继续吧！',
  ];

  static String _pick(List<String> list) => list[_rnd.nextInt(list.length)];

  /// 启动时预热，避免第一次读题卡顿
  static Future<void> warmup() async {
    if (!ProgressStore().voiceOn) return;
    try {
      await _ensure();
    } catch (_) {}
  }

  static Future<void> _ensure() async {
    if (_ready) return;
    _tts = FlutterTts();
    try {
      await _tts?.setLanguage('zh-CN');
      await _tts?.setSpeechRate(0.48);
      await _tts?.setPitch(1.05);
      await _tts?.setVolume(1.0);
    } catch (_) {}
    _ready = true;
  }

  static Future<void> say(String text) async {
    if (!ProgressStore().voiceOn || text.trim().isEmpty) return;
    try {
      await _ensure();
      await _tts?.stop();
      await _tts?.speak(text);
    } catch (_) {
      // 没有 TTS 引擎时静默，不影响游戏
    }
  }

  static Future<void> cheer() => say(_pick(_cheer));
  static Future<void> encourage() => say(_pick(_encourage));
  static Future<void> celebrate() => say(_pick(_celebrate));
  static Future<void> welcome() => say('你好呀，我是小狐狸。我们一起玩思维小岛吧！');
  static Future<void> sticker() => say('哇，新的贴纸！你真棒！');
}
