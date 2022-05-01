part of '../common.dart';

typedef AnimationDataMap = Map<String, RAnimationData>;

class RAnimationData {
  final String pic;
  final Map<String, RAnimationItemData> animations;
  final Vector2? srcSize;

  RAnimationData({
    required this.pic,
    required this.animations,
    required this.srcSize,
  });

  factory RAnimationData.fromJson(Map<String, dynamic> json) {
    return RAnimationData(
      pic: json['pic'],
      animations: Map.from(json['animations']).map(
        (key, value) => MapEntry(key, RAnimationItemData.fromJson(value)),
      ),
      srcSize: utils.vec2fromJson(json['srcSize']),
    );
  }

  RAnimationItemData? getAnimation(String animationName) =>
      animations[animationName];

  Future<Map<T, SpriteAnimation>> getAnimationsMap<T extends Enum>(
    List<T> enumValues,
    String name,
  ) async {
    final imageData = R.getImageData(pic);
    final img = await imageData.image;
    final sheet = SpriteSheet(
      image: img,
      // 优先获取动画的尺寸，如果没有则拿图片自带的，都没有就报错。
      srcSize: srcSize ?? imageData.srcSize!,
    );
    return Map.fromEntries(enumValues.map((e) {
      // 获取对应动画
      final aniData = getAnimation(e.name)!;
      return MapEntry(e, aniData.createAnimationBySheet(sheet));
    }));
  }
}

class RAnimationItemData {
  final int row;
  final int? to;
  final double stepTime;
  final bool loop;

  RAnimationItemData({
    required this.row,
    this.to,
    required this.stepTime,
    this.loop = true,
  });

  factory RAnimationItemData.fromJson(Map<String, dynamic> json) {
    return RAnimationItemData(
      row: json['row'],
      to: json['to'],
      stepTime: json['stepTime'],
      loop: json['loop'] ?? true,
    );
  }

  /// 根据动画表创建一个动画
  SpriteAnimation createAnimationBySheet(SpriteSheet sheet) {
    return sheet.createAnimation(
      row: row,
      stepTime: stepTime,
      to: to,
      loop: loop,
    );
  }
}
