part of '../index.dart';

class RTileCombine extends RTileBase {

  final List<int> combines;

  RTileCombine({
    required this.combines,
    required int id,
    required Vector2 pos,
    required Vector2 size,
    required String type,
    required String? subType,
  }) : super(
          id: id,
          type: type,
          subType: subType,
        );
}

class RTileCombinedPic  {

}
