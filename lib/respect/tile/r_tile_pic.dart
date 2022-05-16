part of '../index.dart';

class RTilePic extends RTileBase {
  final String pic;

  /// 位置 默认为0
  final int x;
  final int y;

  final int w;
  final int h;

  RTilePic({
    required this.pic,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    required int id,
    required String type,
    required String? subType,
  }) : super(
          id: id,
          type: type,
          subType: subType,
        );
}