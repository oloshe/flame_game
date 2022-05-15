part of '../index.dart';

/// 可碰撞的瓦片
class RTileHit extends RTileBase {

  /// 碰撞多边形绘制，如果[hit]为true生效
  /// 如果为null则为默认的矩形碰撞，调用[PolygonComponent.relative]
  final List<Vector2>? polygon;

  /// 锚地，位置会自动矫正，所以不会影响位置。主要用于做层级的划分，例如树，普通的就没必要设了
  final Anchor? anchor;

  RTileHit({
    required this.polygon,
    required this.anchor,
    required int id,
    required Vector2 pos,
    required Vector2 size,
    required String type,
    required String? subType,
  }) : super(
          id: id,
          pos: pos,
          size: size,
          type: type,
          subType: subType,
        );
}
