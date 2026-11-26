import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_info.dart';
import 'screens/home.dart';
import 'store.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 首帧之前不做任何可能卡住的等待：屏幕方向、存档读取都放到后台，
  // 这样即使某个平台通道在个别机型上迟迟不回调，界面也能先画出来。
  unawaited(
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .catchError((Object _) {}),
  );
  unawaited(ProgressStore().load().catchError((Object _) {}));

  runApp(const LogicQuestApp());
}

class LogicQuestApp extends StatelessWidget {
  const LogicQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppInfo.name,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const HomeScreen(),
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        minScaleFactor: 1.0,
        maxScaleFactor: 1.2,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
