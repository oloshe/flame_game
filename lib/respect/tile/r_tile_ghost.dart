part of '../index.dart';

class RTileGhost extends RTilePic {
  RTileGhost({
    required List<int> combines,
    required int id,
    required Vector2 pos,
    required Vector2 size,
    required String type,
    required String? subType,
  }) : super(
          pic: "",
          combines: combines,
          id: id,
          pos: pos,
          size: size,
          type: type,
          subType: subType,
        );
}
