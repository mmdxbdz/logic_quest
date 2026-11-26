// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

/// 把白底生成的动物图抠成透明背景的小图，输出到 assets/animals/。
///
/// 用法：flutter test tool/process_sprites.dart
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('key out white background', () async {
    final dir = Directory('assets/animals_raw');
    final outDir = Directory('assets/animals');
    if (!outDir.existsSync()) outDir.createSync(recursive: true);

    for (final file in dir.listSync().whereType<File>()) {
      if (!file.path.endsWith('.png')) continue;
      final name = file.uri.pathSegments.last.replaceAll('.png', '');
      final bytes = file.readAsBytesSync();

      final ui.Codec codec;
      final ui.FrameInfo frame;
      try {
        codec = await ui.instantiateImageCodec(bytes);
        frame = await codec.getNextFrame();
      } catch (_) {
        print('$name: 不是有效图片，跳过');
        continue;
      }
      final image = frame.image;
      final w = image.width;
      final h = image.height;
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final px = Uint8List.fromList(data!.buffer.asUint8List());

      bool isBackground(int x, int y) {
        final i = (y * w + x) * 4;
        final r = px[i], g = px[i + 1], b = px[i + 2];
        final mx = math.max(r, math.max(g, b));
        final mn = math.min(r, math.min(g, b));
        // 中性色（r≈g≈b）且足够亮 —— 白底和它的柔和阴影都算背景
        return (mx - mn) <= 9 && mx >= 182;
      }

      final removed = Uint8List(w * h);
      final queue = <int>[];
      for (var x = 0; x < w; x++) {
        for (final y in [0, h - 1]) {
          if (isBackground(x, y) && removed[y * w + x] == 0) {
            removed[y * w + x] = 1;
            queue.add(y * w + x);
          }
        }
      }
      for (var y = 0; y < h; y++) {
        for (final x in [0, w - 1]) {
          if (isBackground(x, y) && removed[y * w + x] == 0) {
            removed[y * w + x] = 1;
            queue.add(y * w + x);
          }
        }
      }
      while (queue.isNotEmpty) {
        final idx = queue.removeLast();
        final x = idx % w;
        final y = idx ~/ w;
        for (final d in const [[1, 0], [-1, 0], [0, 1], [0, -1]]) {
          final nx = x + d[0];
          final ny = y + d[1];
          if (nx < 0 || ny < 0 || nx >= w || ny >= h) continue;
          final n = ny * w + nx;
          if (removed[n] == 1) continue;
          if (!isBackground(nx, ny)) continue;
          removed[n] = 1;
          queue.add(n);
        }
      }

      var keEpCount = 0;
      for (var i = 0; i < w * h; i++) {
        if (removed[i] == 1) {
          px[i * 4 + 3] = 0;
        } else {
          keEpCount++;
        }
      }

      // 羽化：让被保留的像素里贴着背景的那一圈半透明，边缘不至于一刀切
      final alpha = Uint8List(w * h);
      for (var i = 0; i < w * h; i++) {
        alpha[i] = removed[i] == 1 ? 0 : px[i * 4 + 3];
      }
      for (var y = 1; y < h - 1; y++) {
        for (var x = 1; x < w - 1; x++) {
          final i = y * w + x;
          if (alpha[i] == 0) continue;
          var sum = 0;
          var cnt = 0;
          for (var dy = -1; dy <= 1; dy++) {
            for (var dx = -1; dx <= 1; dx++) {
              sum += alpha[(y + dy) * w + (x + dx)];
              cnt++;
            }
          }
          final avg = sum ~/ cnt;
          if (avg > 0 && avg < 255) {
            px[i * 4 + 3] = math.min(px[i * 4 + 3], (avg * 1.35).round().clamp(0, 255));
          }
        }
      }

      // 裁剪到内容包围盒
      var minX = w, minY = h, maxX = 0, maxY = 0;
      for (var y = 0; y < h; y++) {
        for (var x = 0; x < w; x++) {
          if (px[(y * w + x) * 4 + 3] > 6) {
            if (x < minX) minX = x;
            if (x > maxX) maxX = x;
            if (y < minY) minY = y;
            if (y > maxY) maxY = y;
          }
        }
      }
      final cw = maxX - minX + 1;
      final ch = maxY - minY + 1;

      final cropped = Uint8List(cw * ch * 4);
      for (var y = 0; y < ch; y++) {
        final src = ((y + minY) * w + minX) * 4;
        cropped.setRange(y * cw * 4, (y + 1) * cw * 4, px, src);
      }

      final croppedImage = await _decode(cropped, cw, ch);
      const target = 420.0;
      final scale = target / math.max(cw, ch);
      final tw = (cw * scale).round();
      final th = (ch * scale).round();
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      canvas.drawImageRect(
        croppedImage,
        ui.Rect.fromLTWH(0, 0, cw.toDouble(), ch.toDouble()),
        ui.Rect.fromLTWH(0, 0, tw.toDouble(), th.toDouble()),
        ui.Paint()..filterQuality = ui.FilterQuality.medium,
      );
      final scaled = await recorder.endRecording().toImage(tw, th);
      final png = await scaled.toByteData(format: ui.ImageByteFormat.png);
      File('${outDir.path}/$name.png').writeAsBytesSync(png!.buffer.asUint8List());

      print('$name: ${w}x$h -> crop ${cw}x$ch -> ${tw}x$th, kept $keEpCount px');
    }
  });
}

Future<ui.Image> _decode(Uint8List pixels, int w, int h) {
  final completer = Completer<ui.Image>();
  ui.decodeImageFromPixels(pixels, w, h, ui.PixelFormat.rgba8888, completer.complete);
  return completer.future;
}
