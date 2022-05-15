part of '../index.dart';

class RTileBase {
  /// tileId
  final int id;

  /// 位置 默认为0
  final Vector2 pos;

  /// 尺寸 不是像素尺寸，是占用的格子
  final Vector2 size;

  /// 分类
  final String type;

  /// 子分类
  final String? subType;

  RTileBase({
    required this.id,
    required this.pos,
    required this.size,
    required this.type,
    required this.subType,
  });
}
