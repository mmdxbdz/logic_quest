# 思维小岛

给 **4-5 岁幼儿园小朋友** 的逻辑思维小游戏（Flutter / Android），**纯离线**，打开就能玩，不需要认字。

## 怎么玩

- 首页是一条**林间小路**：底图是 3D 渲染的森林小路（`assets/home_bg.png`），镜头以消失点为中心缓缓往里推、还带走路时的上下颠簸，看着像一步一步往林子里走；6 颗彩色踏石按透视摆在路上、越远越小，点橡果进对应的小岛。
- 六座岛变成六颗**掉在小路上的橡果**，顺着小路左右歪着散落、越远越小；点哪一颗，小路左边的小松鼠就伸手把那一颗抱进怀里，然后镜头跟着走进去。
- 路边还有蹦蹦跳跳的小兔子和小狐狸陪着一起加油（`assets/animals/`）。
- 每座岛 **8 关**，每关 3 颗星；上一关拿到星星，下一关自动解锁。
- **六个小岛按顺序解锁**：走完前一座岛的 8 关，后一座岛才会打开，锁着的踏石是灰色的、带小锁。
- 每关 4 道小题（迷宫、翻牌是整关一个玩法），答对得星星，答错可以再试一次，不会卡住。
- 小狐狸会用**中文语音读题**、鼓励和报喜；题目同时用大图标显示，不认字也能玩。
- 星星越多，**贴纸册**里解锁的贴纸越多（每 2 颗星一张，共 24 张）。
- 没有倒计时、没有失败惩罚，适合每天玩 5-10 分钟。

## 六个岛的玩法

| 小岛 | 练什么 | 玩法 |
| --- | --- | --- |
| 🎨 找规律 | 规律、序列、推理 | 看一串图案（ABAB / AABB / ABC…），选出接下来是什么 |
| 🧺 分类配对 | 分类、归纳、观察 | 找出"不一样的"；或者找出"一样的两个" |
| 🧭 空间方位 | 上下左右、路径规划 | 看场景说方位（小猫在盒子哪边）；Lv4 起走小迷宫 |
| 🔢 数与量 | 数数、比多少、一样多、数字顺序 | 数一数、点多的那边、补数字、找一样多的一排 |
| 🃏 翻牌记忆 | 短时记忆、专注 | 翻开卡片，把一样的配成一对 |
| 🧩 图形拼搭 | 图形识别、影子配对、图形规则 | 认影子；3×3 图形矩阵里补上缺的一块 |

关卡难度随等级递进，从 2 个图案、3 个数、2 对牌，逐步到 3 个图案、10 个数、6 对牌、5×5 迷宫。

## 设计原则（按 4-5 岁）

- 不依赖文字：题目都用图标、数字、颜色、表情呈现，语音把题目读出来。
- 按钮大：答案卡片最小 64dp，迷宫方向键 62dp，避免点不中。
- 只表扬、不淘汰：答错可再试一次，第二次仍错会显示正确答案再继续，不会失败退出。
- 无时间压力：没有倒计时，孩子可以慢慢看。
- 短回合：每关 4 道题，几分钟结束，保护注意力。
- 声音可关：家长设置里可以关掉语音和音效。

## 项目结构

```
lib/
  main.dart                 入口（加载存档、竖屏）
  app_info.dart             应用名 / 版本 / 隐私文案
  theme.dart                森林绿 + 木牌 + 奶油配色
  models.dart               六个岛、题目、迷宫、翻牌数据模型
  store.dart                本地进度（星星、语音开关、贴纸）
  speech.dart               中文语音（flutter_tts）
  soundfx.dart              运行时合成的音效 WAV（audioplayers）
  content/
    islands.dart            六个岛的定义
    stickers.dart           24 张奖励贴纸
  gen/                      出题器（纯 Dart，可单测）
    util.dart               随机与数字选项工具
    pattern.dart            找规律
    classify.dart           分类 / 配对
    spatial.dart            方位 + 迷宫
    numbers.dart            数与量
    memory.dart             翻牌记忆
    shapes.dart             影子 + 图形矩阵
    levels.dart             按岛和关卡分发
  screens/
    home.dart               首页（3D 渲染底图 + 木牌 + 散落的橡果 + 小松鼠捡橡果）
    island.dart             选关
    choice_game.dart        选择题通用界面
    memory_game.dart        翻牌记忆
    maze_game.dart          小迷宫
    result.dart             结算（星星、新贴纸）
    stickers.dart           贴纸册
    parent.dart             家长设置
    level_router.dart       按岛选择界面
  widgets/                  小狐狸、答案卡片、场景、星星、彩纸
assets/
  home_bg.png               首页 3D 渲染底图
  animals/                  小动物与橡果的透明背景精灵图
tool/
  process_sprites.dart      把白底生成的动物图抠成透明背景（flutter test tool/process_sprites.dart）
test/                       出题规则、存档、48 关渲染测试
```

## 开发环境

与 `math_quest` 相同，构建脚本会自动探测（也可用环境变量 `FLUTTER_HOME` / `JDK_HOME` / `ANDROID_SDK_ROOT` 指定）：

- Flutter SDK：`G:\dev\flutter`
- JDK 17：`G:\dev\jdk17`
- Android SDK：`G:\dev\android-sdk`

项目已内置国内镜像（Gradle wrapper 用腾讯云，Maven 仓库优先 aliyun），国内网络可直接构建。

## 构建与安装

```
powershell -File build.ps1
```

产物：`build\app\outputs\flutter-apk\app-release.apk`（通用包，约 47 MB，含 arm64-v8a / armeabi-v7a / x86_64；支持 Android 7.0 及以上）。
也可以直接使用现成的：`dist\logic-quest.apk`（每次 `build.ps1` 成功后会自动更新这个文件）。

安装到手机：
1. 把 APK 传到手机（微信文件传输助手 / 数据线 / 网盘）。
2. 点开 APK，允许"安装未知来源应用"。
3. 桌面出现「思维小岛」图标，点开即玩，全程无需联网。

## 家长设置

在首页**长按右上角齿轮**进入：

- 语音与音效开关
- 重置全部进度
- 关于与隐私

## 语音说明

语音使用手机系统自带的中文 TTS（文字转语音）。大多数手机（小米、华为、OPPO、vivo、荣耀等）都带中文语音包；如果某台手机没有中文语音包，题目文字和图标仍然正常显示，游戏照常可玩，家长可在设置里关掉声音。

## 隐私

- 纯离线：没有网络权限（release 包不申请 INTERNET），没有账号、广告、统计上报。
- 所有进度（星星、关卡、贴纸、语音开关）只存在本机 SharedPreferences。
- 卸载应用即清除全部数据；家长设置里也可一键重置。
- 题库全部由程序随机生成，玩法和界面为原创。

## 可以怎么调

- 每关题量：改 `lib/screens/choice_game.dart` 里 `buildPuzzles` 生成数量，或改 `lib/gen/*` 返回的列表长度。
- 难度曲线：改 `lib/gen/pattern.dart` 的 `_specs`、`lib/gen/numbers.dart` 的 `buildNumbers`、`lib/gen/memory.dart` 的 `_pairs`。
- 加新玩法：在 `models.dart` 加题目类型 → `gen/` 加生成器 → `widgets/puzzle_views.dart` 加渲染 → `levels.dart` 分发。
- 改名：`lib/app_info.dart` 和 `android/app/src/main/AndroidManifest.xml` 的 `android:label`。
- 换图标：替换 `android/app/src/main/res/mipmap-*/ic_launcher.png`。

## 测试

```
flutter analyze
flutter test
```

覆盖：六类题目的答案正确性、所有迷宫可达性、存档/解锁/贴纸规则、48 个关卡界面的渲染（360×640）。
