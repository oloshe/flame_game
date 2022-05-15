part of '../index.dart';

class RTileObject extends RTileHit {
  /// tile 名 主要用于对象创建时的区分
  final String name;
  RTileObject({
    required this.name,
    required List<Vector2>? polygon,
    required Anchor? anchor,
    required int id,
    required Vector2 pos,
    required Vector2 size,
    required String type,
    required String? subType,
  }) : super(
          polygon: polygon,
          anchor: anchor,
          id: id,
          pos: pos,
          size: size,
          type: type,
          subType: subType,
        );
}
