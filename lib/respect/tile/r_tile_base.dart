part of '../index.dart';

typedef TileIdMap = Map<int, RTileBase>;

abstract class RTileBase {
  /// tileId
  final int id;

  /// 分类
  final String type;

  /// 子分类
  final String? subType;

  RTileBase({
    required this.id,
    required this.type,
    required this.subType,
  });

  static Future<TileIdMap> load() async {
    final jsonData = await Flame.assets.readJson("${R.jsonPath}tile.json");
    TileIdMap result = {};
    Future<void> _loadJson(Map<String, dynamic> json,
        [RTilePartialData? partialData]) async {
      for (final item in json.entries) {
        final _key = int.tryParse(item.key);
        if (_key != null) {
          result[_key] = RTileBase.fromJson(
            _key,
            item.value,
            fallbackData: partialData,
          );
        } else {
          final partialData = RTilePartialData.fromJson(item.value);
          final subJson = await Flame.assets.readJson(
            "${R.jsonPath}${partialData.source}",
          );
          await _loadJson(subJson, partialData);
        }
      }
    }

    await _loadJson(jsonData);
    return result;
  }

  factory RTileBase.fromJson(
    int id,
    Map<String, dynamic> json, {
    RTilePartialData? fallbackData,
  }) {
    String? pic = json['pic'] ?? fallbackData?.pic;
    List<int>? combines = json.getList('combines')?.cast<int>();
    String type = json['type'] ?? fallbackData?.type;
    String? subType = json['subType'] ?? fallbackData?.subType;
    if (pic == null) {
      if (combines != null) {
        return RTileCombine(
            combines: combines, id: id, type: type, subType: subType);
      } else {
        print(json);
        throw UnimplementedError();
      }
    }
    int x = json['pos']?[0] ?? 1;
    int y = json['pos']?[1] ?? 1;
    int w = json['size']?[0] ?? 1;
    int h = json['size']?[1] ?? 1;
    if (json['hit'] == true) {
      String? name = json['name'];
      final polygon = json.getList('polygon')?.toVector2List();
      final anchor = json.getList('anchor')?.toAnchor();
      if (name != null) {
        return RTileObject(
          name: name,
          polygon: polygon,
          anchor: anchor,
          pic: pic,
          id: id,
          x: x,
          y: y,
          w: w,
          h: h,
          type: type,
          subType: subType,
          combines: combines,
        );
      }
      return RTileHit(
        pic: pic,
        polygon: polygon,
        anchor: anchor,
        id: id,
        x: x,
        y: y,
        w: w,
        h: h,
        type: type,
        subType: subType,
        combines: combines,
      );
    }
    return RTilePic(
      pic: pic,
      x: x,
      y: y,
      w: w,
      h: h,
      id: id,
      type: type,
      subType: subType,
      combines: combines,
    );
  }

  Vector2 get size => Vector2(1, 1);

  Vector2 get spriteSize;

  void batchConfiguration(
    Map<String, SpriteBatch> batch,
    Vector2 position,
  ) {
    final tileIter = (this as RCombine).getPicTiles();
    for (final tile in tileIter) {
      final sprite = tile.getSprite();
      final picAlias = tile.pic;
      if (!batch.containsKey(picAlias)) {
        batch[picAlias] = SpriteBatch(sprite.image);
      }
      batch[picAlias]!.add(
        source: Rect.fromLTWH(
          sprite.srcPosition.x,
          sprite.srcPosition.y,
          sprite.srcSize.x,
          sprite.srcSize.y,
        ),
        scale: RespectMap.scaleFactor,
        offset: position,
      );
    }
  }
}

class RTilePartialData {
  /// 指定图片名，减少数据冗余
  final String pic;

  /// 类型
  final String type;

  /// 子类型
  final String? subType;

  /// 路径
  final String? terrain;

  /// 文件路径
  final String source;

  RTilePartialData({
    required this.pic,
    required this.type,
    required this.source,
    required this.terrain,
    required this.subType,
  });

  factory RTilePartialData.fromJson(Map<String, dynamic> json) {
    return RTilePartialData(
      pic: json["pic"],
      type: json["type"],
      source: json["source"],
      terrain: json["terrain"],
      subType: json["subType"],
    );
  }
}
