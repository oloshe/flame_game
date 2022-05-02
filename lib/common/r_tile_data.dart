part of '../common.dart';

typedef TileDataIdMap = Map<int, RTileData>;

class RTileData {
  /// tileId
  // final String id;
  final String pic;

  /// 位置 默认为0
  final Vector2 pos;

  /// 尺寸 不是像素尺寸，是占用的格子
  final Vector2 size;

  /// 分类
  final String type;

  RTileData({
    // required this.id,
    required this.pic,
    required this.pos,
    required this.size,
    required this.type
  });

  factory RTileData.fromJson(Map<String, dynamic> json) {
    int w = json['width'] ?? 1;
    int h = json['height'] ?? 1;
    return RTileData(
      pic: json['pic'],
      pos: utils.vec2fromJsonDefault(json['pos']),
      size: Vector2(w.toDouble(), h.toDouble()),
      type: json['type'],
    );
  }

  Future<Image> getImage() {
    return R.getImageByAlias(pic);
  }

  Future<Sprite> getSprite() async {
    RImageData imgData = R.getImageData(pic);
    Vector2 srcPosition = pos.clone();
    Vector2? srcSize = imgData.srcSize?.clone();
    if (srcSize != null) {
      srcPosition.multiply(srcSize);
      srcSize.multiply(size);
    }
    return Sprite(
      await imgData.image,
      srcSize: srcSize,
      srcPosition: srcPosition,
    );
  }
}
