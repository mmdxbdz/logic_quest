/// 应用信息（改名只需改这里 + AndroidManifest 的 android:label）
class AppInfo {
  static const String name = '思维小岛';
  static const String version = '1.0.0';

  /// 隐私与关于说明（家长页展示）
  static const List<String> privacy = [
    '本应用纯离线运行，不需要网络，也不需要注册账号。',
    '不收集任何个人信息：没有账号、没有统计上报、没有广告。',
    '所有星星、贴纸和闯关记录只保存在本机。',
    '所有题目由程序随机生成，玩法为原创设计。',
    '如需彻底清除数据：家长设置 → 重置全部进度，或卸载应用。',
  ];
}
