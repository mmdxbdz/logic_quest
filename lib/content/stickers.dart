/// 24 张奖励贴纸：每 2 颗星解锁一张。
class StickerDef {
  final String emoji;
  final String name;
  const StickerDef(this.emoji, this.name);
}

const List<StickerDef> stickers = [
  StickerDef('🐣', '小鸡'),
  StickerDef('🐼', '熊猫'),
  StickerDef('🦁', '狮子'),
  StickerDef('🐘', '大象'),
  StickerDef('🦒', '长颈鹿'),
  StickerDef('🦋', '蝴蝶'),
  StickerDef('🐳', '鲸鱼'),
  StickerDef('🐙', '章鱼'),
  StickerDef('🚀', '火箭'),
  StickerDef('⛵', '帆船'),
  StickerDef('🌈', '彩虹'),
  StickerDef('🐢', '小乌龟'),
  StickerDef('🍓', '草莓'),
  StickerDef('🍩', '甜甜圈'),
  StickerDef('🍦', '冰淇淋'),
  StickerDef('🌻', '向日葵'),
  StickerDef('🌵', '仙人掌'),
  StickerDef('⭐', '星星'),
  StickerDef('🌙', '月亮'),
  StickerDef('☀️', '太阳'),
  StickerDef('🎈', '气球'),
  StickerDef('🎁', '礼物'),
  StickerDef('🏰', '城堡'),
  StickerDef('👑', '王冠'),
];

int stickerThreshold(int index) => (index + 1) * 2;
