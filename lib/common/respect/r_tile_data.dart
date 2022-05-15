part of '../../common.dart';

typedef TileDataIdMap = Map<int, RTileData>;

class RTileData {
  /// tileId
  final int id;

  // 图片别名
  final String pic;

  /// 位置 默认为0
  final Vector2 pos;

  /// 尺寸 不是像素尺寸，是占用的格子
  final Vector2 size;

  /// 分类
  final String type;

  /// 子分类
  final String? subType;

  /// 是否为对象 如果是则根据 [name] 用 [R.getTileObjectBuilder] 获取创建方法
  final bool? object;
  /// tile 名
  final String name;

  /// 是否是碰撞体，默认为false
  final bool hit;

  /// 碰撞多边形绘制，如果[hit]为true生效
  /// 如果为null则为默认的矩形碰撞，调用[PolygonComponent.relative]
  final List<Vector2>? polygon;

  // /// 是否开启阻挡
  // final bool? cover;

  // 锚地，位置会自动矫正，所以不会影响位置。主要用于做层级的划分，例如树
  final Anchor? anchor;

  // 将连个tile结合，该图层会在最上层
  final int? combine;

  RTileData({
    required this.id,
    required this.pic,
    required this.pos,
    required this.size,
    required this.type,
    required this.subType,
    required this.hit,
    required this.polygon,
    // required this.cover,
    required this.object,
    required this.name,
    required this.anchor,
    required this.combine,
  });

  factory RTileData.fromJson(int id, Map<String, dynamic> json) {
    int w = json['width'] ?? 1;
    int h = json['height'] ?? 1;
    return RTileData(
      id: id,
      pic: json['pic'],
      pos: json.getList('pos').toVector2() ?? Vector2.zero(),
      size: Vector2(w.toDouble(), h.toDouble()),
      type: json['type'],
      subType: json['subType'],
      hit: json['hit'] ?? false,
      polygon: json.getList('polygon')?.toVector2List(),
      // cover: json['cover'],
      object: json['object'],
      name: json['name'] ?? '',
      anchor: json.getList('anchor')?.toAnchor(),
      combine: json['combine'],
    );
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

  Vector2 get spriteSize => size.clone()..multiply(RespectMap.base);

  bool get isCombine => combine != null;

  RTileData? get combineTile => combine != null ? R.getTileById(combine!) : null;

  /// 迭代获取嵌套的引用tile
  Iterable<RTileData> getCombinedTiles() sync* {
    RTileData curr = this;
    while(curr.isCombine) {
      final tile = curr.combineTile;
      if (tile != null) {
        curr = tile;
        yield curr;
      } else {
        break;
      }
    }
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
