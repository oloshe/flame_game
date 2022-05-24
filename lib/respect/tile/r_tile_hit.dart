part of '../index.dart';

/// 可碰撞的瓦片
class RTileHit extends RTilePic {
  /// 碰撞多边形绘制，如果[hit]为true生效
  /// 如果为null则为默认的矩形碰撞，调用[PolygonComponent.relative]
  final List<Vector2>? polygon;

  /// 锚地，位置会自动矫正，所以不会影响位置。主要用于做层级的划分，例如树，普通的就没必要设了
  final Anchor? anchor;

  RTileHit({
    required String pic,
    required this.polygon,
    required this.anchor,
    required int id,
    required int x,
    required int y,
    required int w,
    required int h,
    required String type,
    required String? subType,
    required List<int>? combines,
    required Rect? displayRect,
  }) : super(
          id: id,
          pic: pic,
          x: x,
          y: y,
          w: w,
          h: h,
          type: type,
          subType: subType,
          combines: combines,
          displayRect: displayRect,
        );

  factory RTileHit.create({
    required String? name,
    required double? circle,
    required String pic,
    required List<Vector2>? polygon,
    required Anchor? anchor,
    required int id,
    required int x,
    required int y,
    required int w,
    required int h,
    required String type,
    required String? subType,
    required List<int>? combines,
    required Rect? displayRect,
  }) {
    if (name == null) {
      return RTileHit(
        pic: pic,
        polygon: polygon,
        anchor: anchor,
        id: id,
        x: x,
        y: y,
        w: w,
        h: h,
        type: type,
        subType: subType,
        combines: combines,
        displayRect: displayRect,
      );
    } else {
      return RTileObject(
        name: name,
        polygon: polygon,
        anchor: anchor,
        pic: pic,
        id: id,
        x: x,
        y: y,
        w: w,
        h: h,
        type: type,
        subType: subType,
        combines: combines,
        displayRect: displayRect,
      );
    }
  }

  Vector2 getAnchorOffset() {
    return (spriteSize..multiply((anchor ?? Anchor.topLeft).toVector2())) -
        (RespectMap.base / 2);
  }

  @override
  String toString() {
    return 'Hit(${polygon ?? 'fill'};${anchor ?? Anchor.topLeft}})->${super.toString()}';
  }
}
