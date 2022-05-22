part of '../index.dart';

class RTileCombine extends RTileBase with RCombine {
  RTileCombine({
    required List<int> combines,
    required int id,
    required String type,
    required String? subType,
    required Rect? displayRect,
  }) : super(
          id: id,
          type: type,
          subType: subType,
          displayRect: displayRect,
        ) {
    combineData = combines;
  }

  @override
  Vector2 get spriteSize => tileSize..multiply(RespectMap.base);

  @override
  String toString() {
    return 'Combine($combineData)->${super.toString()}';
  }
}

mixin RCombine on RTileBase {
  List<int>? combineData;

  Iterable<RTilePic> getPicTiles() sync* {
    if (combineData == null) {
      if (this is RTilePic) {
        yield (this as RTilePic);
      }
      return;
    }
    for (final id in combineData!) {
      final tmp = R.getTileById(id);
      if (tmp != null) {
        if (tmp is RTilePic) {
          yield tmp;
        }
      }
    }
    if (this is RTilePic) {
      yield (this as RTilePic);
    }
  }
}
