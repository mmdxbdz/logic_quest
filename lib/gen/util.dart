import 'dart:math';
import '../models.dart';

int ri(Random rnd, int min, int max) => min + rnd.nextInt(max - min + 1);

T pick<T>(Random rnd, List<T> list) => list[rnd.nextInt(list.length)];

List<T> shuffled<T>(Random rnd, List<T> list) => [...list]..shuffle(rnd);

/// 生成若干数字选项（含正确答案）
List<OptionSpec> numberOptions(
  Random rnd,
  int correct, {
  int count = 3,
  int min = 1,
  int max = 10,
}) {
  final values = <int>{correct};
  var guard = 0;
  while (values.length < count && guard < 200) {
    guard++;
    final delta = ri(rnd, 1, 2) * (rnd.nextBool() ? 1 : -1);
    final v = correct + delta;
    if (v >= min && v <= max) values.add(v);
  }
  var extra = 1;
  while (values.length < count) {
    if (correct + extra <= max) values.add(correct + extra);
    if (values.length < count && correct - extra >= min) values.add(correct - extra);
    extra++;
  }
  final list = values.toList()..shuffle(rnd);
  return [for (final v in list) OptionSpec(text: '$v')];
}

int indexOfOption(List<OptionSpec> options, String text) =>
    options.indexWhere((o) => o.text == text);
