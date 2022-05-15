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
  final String? name;

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
  final List<int>? combines;
  // 没有实际数据，全是combines
  final bool ghost;

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
    required this.combines,
    required this.ghost,
  });

  static Future<TileDataIdMap> load() async {
    final jsonData = await Flame.assets.readJson("${R.jsonPath}tile.json");
    TileDataIdMap result = {};
    Future<void> _loadJson(Map<String, dynamic> json,
        [RTileTerrainData? terrainData]) async {
      for (final item in json.entries) {
        final _key = int.tryParse(item.key);
        if (_key != null) {
          result[_key] = RTileData.fromJson(_key, item.value, terrainData);
        } else {
          final terrainData = RTileTerrainData.fromJson(item.value);
          final subJson = await Flame.assets.readJson(
            "${R.jsonPath}${terrainData.source}",
          );
          await _loadJson(subJson, terrainData);
        }
      }
    }

    await _loadJson(jsonData);
    return result;
  }

  factory RTileData.fromJson(int id, Map<String, dynamic> json,
      [RTileTerrainData? terrainData]) {
    int w = json['width'] ?? 1;
    int h = json['height'] ?? 1;
    return RTileData(
      id: id,
      pic: json['pic'] ?? terrainData?.pic,
      pos: json.getList('pos').toVector2() ?? Vector2(0, 0),
      size: Vector2(w.toDouble(), h.toDouble()),
      type: json['type'] ?? terrainData?.type,
      subType: json['subType'],
      hit: json['hit'] ?? false,
      polygon: json.getList('polygon')?.toVector2List(),
      // cover: json['cover'],
      object: json['object'],
      name: json['name'],
      anchor: json.getList('anchor')?.toAnchor(),
      combines: json.getList('combines')?.cast<int>(),
      ghost: json['combines'] != null || json['pos'] == null,
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

  bool get isCombine => combines != null && combines!.isNotEmpty;

  /// 迭代获取嵌套的引用tile
  Iterable<RTileData> getCombinedTiles() sync* {
    if (isCombine) {
      for (var id in combines!) {
        final tmp = R.getTileById(id);
        if (tmp != null) {
          yield tmp;
        }
      }
    }
    if (!ghost) {
      yield this;
    }
  }

  Future<void> batchRender(
    Map<String, SpriteBatch> batch,
    Vector2 spritePosition,
  ) async {
    final iter = getCombinedTiles();
    for (final tile in iter) {
      final sp = await tile.getSprite();
      final pic = tile.pic;
      if (!batch.containsKey(pic)) {
        batch[pic] = SpriteBatch(sp.image);
      }
      batch[pic]!.add(
        source: Rect.fromLTWH(
          sp.srcPosition.x,
          sp.srcPosition.y,
          sp.srcSize.x,
          sp.srcSize.y,
        ),
        scale: RespectMap.scaleFactor,
        offset: spritePosition,
      );
    }
  }

  void batchRenderSync(
    Map<String, SpriteBatch> batch,
    Vector2 spritePosition,
    Map<int, Sprite> cache,
  ) {
    final iter = getCombinedTiles();
    for (final tile in iter) {
      final sp = cache[tile.id]!;
      final pic = tile.pic;
      if (!batch.containsKey(pic)) {
        batch[pic] = SpriteBatch(sp.image);
      }
      batch[pic]!.add(
        source: Rect.fromLTWH(
          sp.srcPosition.x,
          sp.srcPosition.y,
          sp.srcSize.x,
          sp.srcSize.y,
        ),
        scale: RespectMap.scaleFactor,
        offset: spritePosition,
      );
    }
  }
}

class RTileTerrainData {
  final String pic;
  final String type;
  final String source;
  final String terrain;
  RTileTerrainData({
    required this.pic,
    required this.type,
    required this.source,
    required this.terrain,
  });

  factory RTileTerrainData.fromJson(Map<String, dynamic> json) {
    return RTileTerrainData(
      pic: json["pic"],
      type: json["type"],
      source: json["source"],
      terrain: json["terrain"],
    );
  }
}
//
// class RCombineData {
//   final List<int> combines;
//   RCombineData(this.combines);
//   factory RCombineData.fromJson(Map<String, dynamic> json) {
//     return RCombineData(json["combines"]);
//   }
// }
