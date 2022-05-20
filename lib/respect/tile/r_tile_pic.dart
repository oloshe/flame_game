part of '../index.dart';

class RTilePic extends RTileBase with RCombine {
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
    required List<int>? combines,
  }) : super(
          id: id,
          type: type,
          subType: subType,
        ) {
    combineData = combines;
  }

  Vector2 get pos => Vector2(x.toDouble(), y.toDouble());
  @override
  Vector2 get size => Vector2(w.toDouble(), h.toDouble());

  @override
  Vector2 get spriteSize => size..multiply(RespectMap.base);

  Sprite getSprite() {
    RImageData imgData = R.getImageData(pic);
    Vector2 srcPosition = pos.clone();
    Vector2? srcSize = imgData.srcSize?.clone();
    if (srcSize != null) {
      srcPosition.multiply(srcSize);
      srcSize.multiply(size);
    }
    return Sprite(
      imgData.image,
      srcSize: srcSize,
      srcPosition: srcPosition,
    );
  }

  @override
  String toString() {
    return 'Pic[$pic;($x,$y);${w}x$h]->${super.toString()}';
  }
}
