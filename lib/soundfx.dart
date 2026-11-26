import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'store.dart';

/// 运行时合成的小音效（WAV），完全离线。
class SoundFx {
  static String? _dingPath;
  static String? _boopPath;
  static String? _popPath;
  static String? _tadaPath;
  static AudioPlayer? _ding;
  static AudioPlayer? _boop;
  static AudioPlayer? _pop;
  static AudioPlayer? _tada;
  static bool _ready = false;

  static Future<void> _ensure() async {
    if (_ready) return;
    try {
      final dir = Directory.systemTemp.createTempSync('logicfx');
      _dingPath = '${dir.path}/ding.wav';
      _boopPath = '${dir.path}/boop.wav';
      _popPath = '${dir.path}/pop.wav';
      _tadaPath = '${dir.path}/tada.wav';
      await File(_dingPath!).writeAsBytes(_synthDing());
      await File(_boopPath!).writeAsBytes(_synthBoop());
      await File(_popPath!).writeAsBytes(_synthPop());
      await File(_tadaPath!).writeAsBytes(_synthTada());
      _ding = AudioPlayer();
      _boop = AudioPlayer();
      _pop = AudioPlayer();
      _tada = AudioPlayer();
      await _ding?.setVolume(0.65);
      await _boop?.setVolume(0.5);
      await _pop?.setVolume(0.45);
      await _tada?.setVolume(0.7);
      _ready = true;
    } catch (_) {
      // 音频不可用不影响游戏
    }
  }

  static bool get _on => ProgressStore().voiceOn;

  static Future<void> ding() async {
    if (!_on) return;
    try {
      await _ensure();
      await _ding?.stop();
      await _ding?.play(DeviceFileSource(_dingPath!), mode: PlayerMode.lowLatency);
    } catch (_) {}
  }

  static Future<void> boop() async {
    if (!_on) return;
    try {
      await _ensure();
      await _boop?.stop();
      await _boop?.play(DeviceFileSource(_boopPath!), mode: PlayerMode.lowLatency);
    } catch (_) {}
  }

  static Future<void> pop() async {
    if (!_on) return;
    try {
      await _ensure();
      await _pop?.stop();
      await _pop?.play(DeviceFileSource(_popPath!), mode: PlayerMode.lowLatency);
    } catch (_) {}
  }

  static Future<void> tada() async {
    if (!_on) return;
    try {
      await _ensure();
      await _tada?.stop();
      await _tada?.play(DeviceFileSource(_tadaPath!), mode: PlayerMode.lowLatency);
    } catch (_) {}
  }

  /// 正确的"叮咚"：两个音往上跳
  static Uint8List _synthDing() {
    const rate = 44100;
    const ms = 380;
    final n = rate * ms ~/ 1000;
    final out = List<double>.filled(n, 0);
    for (var i = 0; i < n; i++) {
      final t = i / rate;
      final env = exp(-t * 9);
      final f1 = 880.0;
      final f2 = t > 0.12 ? 1318.5 : 0.0;
      out[i] = (sin(2 * pi * f1 * t) * 0.55 + (f2 > 0 ? sin(2 * pi * f2 * (t - 0.12)) * 0.45 : 0)) * env;
    }
    return _wav(out, rate);
  }

  /// 错误的"波"：往下滑的柔和音
  static Uint8List _synthBoop() {
    const rate = 44100;
    const ms = 220;
    final n = rate * ms ~/ 1000;
    final out = List<double>.filled(n, 0);
    for (var i = 0; i < n; i++) {
      final t = i / rate;
      final p = i / n;
      final env = sin(pi * p) * exp(-p * 3);
      final f = 320 - 140 * p;
      out[i] = sin(2 * pi * f * t) * env * 0.7;
    }
    return _wav(out, rate);
  }

  /// 点击的"啵"
  static Uint8List _synthPop() {
    const rate = 44100;
    const ms = 90;
    final n = rate * ms ~/ 1000;
    final out = List<double>.filled(n, 0);
    for (var i = 0; i < n; i++) {
      final t = i / rate;
      final env = exp(-t * 40);
      out[i] = sin(2 * pi * 720 * t) * env * 0.6;
    }
    return _wav(out, rate);
  }

  /// 过关的"叮叮叮叮"
  static Uint8List _synthTada() {
    const rate = 44100;
    const ms = 900;
    final n = rate * ms ~/ 1000;
    final out = List<double>.filled(n, 0);
    const notes = [523.25, 659.25, 783.99, 1046.5];
    for (var k = 0; k < notes.length; k++) {
      final start = (k * 0.13 * rate).round();
      final len = (rate * 0.32).round();
      for (var i = 0; i < len; i++) {
        final idx = start + i;
        if (idx >= n) break;
        final t = i / rate;
        final env = exp(-t * 7);
        out[idx] += sin(2 * pi * notes[k] * t) * env * 0.38;
      }
    }
    return _wav(out, rate);
  }

  static Uint8List _wav(List<double> samples, int rate) {
    final b = BytesBuilder();
    void u16(int v) {
      b.addByte(v & 0xFF);
      b.addByte((v >> 8) & 0xFF);
    }

    void u32(int v) {
      b.addByte(v & 0xFF);
      b.addByte((v >> 8) & 0xFF);
      b.addByte((v >> 16) & 0xFF);
      b.addByte((v >> 24) & 0xFF);
    }

    b.add([0x52, 0x49, 0x46, 0x46]); // RIFF
    u32(36 + samples.length * 2);
    b.add([0x57, 0x41, 0x56, 0x45]); // WAVE
    b.add([0x66, 0x6D, 0x74, 0x20]); // fmt
    u32(16);
    u16(1); // PCM
    u16(1); // mono
    u32(rate);
    u32(rate * 2);
    u16(2);
    u16(16);
    b.add([0x64, 0x61, 0x74, 0x61]); // data
    u32(samples.length * 2);
    for (final s in samples) {
      final v = (s.clamp(-1.0, 1.0) * 32767).round();
      b.addByte(v & 0xFF);
      b.addByte((v >> 8) & 0xFF);
    }
    return b.toBytes();
  }
}
