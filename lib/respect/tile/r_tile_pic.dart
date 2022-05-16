part of '../index.dart';

class RTilePic extends RTileBase {
  final String pic;
  final List<int> combines;
  RTilePic({
    required this.pic,
    required this.combines,
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