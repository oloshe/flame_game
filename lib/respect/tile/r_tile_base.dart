part of '../index.dart';

typedef TileIdMap = Map<int, RTileBase>;

class RTileBase {
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
  //
  // static Future<TileIdMap> load() async {
  //   final jsonData = await Flame.assets.readJson("${R.jsonPath}tile.json");
  //   TileIdMap result = {};
  //   Future<void> _loadJson(Map<String, dynamic> json,
  //       [RTilePartialData? terrainData]) async {
  //     for (final item in json.entries) {
  //       final _key = int.tryParse(item.key);
  //       if (_key != null) {
  //         result[_key] = RTileBase.fromJson(_key, item.value, terrainData);
  //       } else {
  //         final terrainData = RTilePartialData.fromJson(item.value);
  //         final subJson = await Flame.assets.readJson(
  //           "${R.jsonPath}${terrainData.source}",
  //         );
  //         await _loadJson(subJson, terrainData);
  //       }
  //     }
  //   }
  //
  //   await _loadJson(jsonData);
  //   return result;
  // }

  // factory RTileBase.fromJson(int id, Map<String, dynamic> json) {
  //
  // }
}
