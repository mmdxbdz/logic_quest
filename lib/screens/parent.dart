import 'package:flutter/material.dart';
import '../app_info.dart';
import '../speech.dart';
import '../store.dart';
import '../theme.dart';

class ParentScreen extends StatefulWidget {
  const ParentScreen({super.key});

  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  final ProgressStore _store = ProgressStore();

  Future<void> _confirmReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('重置全部进度？'),
        content: const Text('星星、关卡、贴纸都会清空，不能恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定重置'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _store.resetAll();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('进度已清空')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Palette.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '家长设置',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: Palette.ink),
        ),
      ),
      body: AnimatedBuilder(
        animation: _store,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '思维小岛适合 4-5 岁的小朋友，每次 5-10 分钟。'
                '全部题目由图形和表情组成，不需要认字；'
                '每一关有 4 道小题，答错可以再试一次，不会卡住。',
                style: TextStyle(fontSize: 14, height: 1.55, color: Palette.ink),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SwitchListTile(
                value: _store.voiceOn,
                onChanged: (v) {
                  _store.setVoice(v);
                  if (v) Speech.say('语音打开啦。');
                },
                title: const Text(
                  '语音与音效',
                  style: TextStyle(fontWeight: FontWeight.w700, color: Palette.ink),
                ),
                subtitle: const Text(
                  '用手机自带的中文语音朗读题目，建议保持打开',
                  style: TextStyle(fontSize: 12, color: Palette.inkSoft),
                ),
                activeTrackColor: Palette.good,
                secondary: const Icon(Icons.volume_up_rounded, color: Palette.inkSoft),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                leading: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFE57373)),
                title: const Text(
                  '重置全部进度',
                  style: TextStyle(fontWeight: FontWeight.w700, color: Palette.ink),
                ),
                subtitle: const Text(
                  '清空星星、关卡和贴纸',
                  style: TextStyle(fontSize: 12, color: Palette.inkSoft),
                ),
                onTap: _confirmReset,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ExpansionTile(
                shape: const Border(),
                leading: const Icon(Icons.info_outline_rounded, color: Palette.inkSoft),
                title: const Text(
                  '关于与隐私',
                  style: TextStyle(fontWeight: FontWeight.w700, color: Palette.ink),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  for (final line in AppInfo.privacy)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('· ', style: TextStyle(color: Palette.inkSoft)),
                          Expanded(
                            child: Text(
                              line,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: Palette.inkSoft,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '${AppInfo.name} v${AppInfo.version}',
                    style: const TextStyle(fontSize: 12, color: Palette.inkSoft),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Center(
              child: Text(
                '家长小贴士：陪孩子一起说题，比答对更重要。',
                style: TextStyle(fontSize: 12, color: Palette.inkSoft),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
