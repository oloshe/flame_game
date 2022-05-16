part of '../index.dart';

class RTileObject extends RTileHit {
  /// tile 名 主要用于对象创建时的区分
  final String name;
  RTileObject({
    required this.name,
    required List<Vector2>? polygon,
    required Anchor? anchor,
    required String pic,
    required int id,
    required int x,
    required int y,
    required int w,
    required int h,
    required String type,
    required String? subType,
  }) : super(
          polygon: polygon,
          anchor: anchor,
          id: id,
          type: type,
          subType: subType,
          x: x,
          y: y,
          w: w,
          h: h,
          pic: pic,
        );
}
