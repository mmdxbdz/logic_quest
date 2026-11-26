import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_quest/content/islands.dart';
import 'package:logic_quest/main.dart';
import 'package:logic_quest/screens/level_router.dart';
import 'package:logic_quest/store.dart';
import 'package:logic_quest/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ProgressStore().load();
  });

  testWidgets('首页显示六个小岛', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const LogicQuestApp());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('思维小岛'), findsOneWidget);
    // 路上散落着六颗橡果
    for (var i = 0; i < islands.length; i++) {
      expect(find.byKey(ValueKey('acorn-$i')), findsOneWidget, reason: '第 $i 颗橡果');
    }
    // 当前（第一个没通关的）小岛会挂出名字牌
    expect(find.text(islands.first.name), findsOneWidget);
  });

  testWidgets('48 个关卡界面都能正常渲染', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final island in islands) {
      for (var level = 1; level <= 8; level++) {
        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: buildTheme(),
            home: levelScreen(island, level),
          ),
        );
        await tester.pump(const Duration(milliseconds: 60));
        expect(
          tester.takeException(),
          isNull,
          reason: '${island.name} 第 $level 关渲染出错',
        );
      }
    }
  });
}
