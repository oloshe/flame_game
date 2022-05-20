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
        [RPartial? partialData]) async {
      for (final item in json.entries) {
        final _key = int.tryParse(item.key);
        if (_key != null) {
          /// 补全信息
          partialData?.supplement(item.value);
          final tileBase = RTileBase.fromJson(
            id: _key,
            json: item.value,
          );
          partialData?.process(tileBase, item.value);
          // if (tileBase.terrain != null) {
          //   R.addTerrain(tileBase.terrain!, tileBase, item.value);
          // }
          result[_key] = tileBase;
        } else {
          final RPartial partialData = RPartial.fromJson(item.value);
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

  factory RTileBase.fromJson({
    required int id,
    required Map<String, dynamic> json,
  }) {
    String? pic = json['pic'];
    List<int>? combines = json.getList('combines')?.cast<int>();
    String type = json['type'];
    String? subType = json['subType'];
    List<dynamic>? pos = json['pos'];
    if (pic == null || pos == null) {
      if (combines != null) {
        return RTileCombine(
          combines: combines,
          id: id,
          type: type,
          subType: subType,
        );
      } else {
        print(json);
        throw UnimplementedError();
      }
    }
    int x = pos[0];
    int y = pos[1];
    int w = json['width'] ?? 1;
    int h = json['height'] ?? 1;
    if (json['hit'] == true) {
      String? name = json['name'];
      final polygon = json.getList('polygon')?.toVector2List();
      final anchor = json.getList('anchor')?.toAnchor();
      return RTileHit.create(
        name: name,
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

  @override
  String toString() {
    return 'Tile($id)';
  }

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
