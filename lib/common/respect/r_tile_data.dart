part of '../../common.dart';

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

  /// 子分类
  final String? subType;

  /// 是否是碰撞体，默认为false
  final bool hit;

  /// 碰撞多边形绘制，如果[hit]为true生效
  /// 如果为null则为默认的矩形碰撞，调用[PolygonComponent.relative]
  final List<Vector2>? polygon;

  /// 遮挡Y值，如果不为null，则玩家Y值小于该值会被覆盖
  final double? cover;

  RTileData({
    // required this.id,
    required this.pic,
    required this.pos,
    required this.size,
    required this.type,
    required this.subType,
    required this.hit,
    required this.polygon,
    required this.cover,
  });

  factory RTileData.fromJson(Map<String, dynamic> json) {
    int w = json['width'] ?? 1;
    int h = json['height'] ?? 1;
    return RTileData(
      pic: json['pic'],
      pos: json.getList('pos').toVector2() ?? Vector2.zero(),
      size: Vector2(w.toDouble(), h.toDouble()),
      type: json['type'],
      subType: json['subType'],
      hit: json['hit'] ?? false,
      polygon: json.getList('polygon')?.toVector2List(),
      cover: json['cover'],
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

// class RTileCoverData {
//   final Vector2 size;
//   final Vector2 offset;
//   RTileCoverData({
//     required this.size,
//     required this.offset,
//   });

//   factory RTileCoverData.fromJson(Map<String, dynamic> json) {
//     return RTileCoverData(
//       size: utils.vec2FieldDefault(json['size']),
//       offset: utils.vec2FieldDefault(json['offset']),
//     );
//   }
// }
