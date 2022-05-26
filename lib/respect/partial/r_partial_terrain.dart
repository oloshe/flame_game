import 'package:game/respect/index.dart';
import 'package:game/respect/partial/r_partial.dart';
import 'package:tuple/tuple.dart';

class RPartialTerrain with RPartialData {
  /// 指定图片名，减少数据冗余
  final String pic;

  /// 类型 减少数据冗余
  final String type;

  /// 子类型 减少数据冗余
  final String? subType;

  /// 路径
  final String terrain;

  /// 封面
  final int cover;

  /// 根据 tileId 获取 test 值
  final Map<int, String> collection;

  /// 路径检测映射
  final Map<String, int> tests;

  final TerrainType terrainType;

  RPartialTerrain({
    required this.pic,
    required this.type,
    required this.terrain,
    required this.subType,
    required this.cover,
    required this.terrainType,
  })  : tests = {},
        collection = {};

  factory RPartialTerrain.fromJson(Map<String, dynamic> json) {
    final result = RPartialTerrain(
      pic: json["pic"],
      type: json["type"],
      terrain: json["terrain"],
      subType: json["subType"],
      cover: json["cover"],
      terrainType: getTerrainType(json['terrainType']),
    );
    // 添加到全局，以用于编辑路径时的使用
    _allTerrains[result.terrain] = result;
    return result;
  }

  @override
  void supplement(Map<String, dynamic> json) {
    if (json["pic"] == null) {
      json["pic"] = pic;
    }
    if (json["type"] == null) {
      json["type"] = type;
    }
    if (json["subType"] == null) {
      json["subType"] = subType;
    }
  }

  @override
  void process(RTileBase tileBase, Map<String, dynamic> json) {
    final id = tileBase.id;
    final String test = json["test"];
    collection[id] = test;
    _idMap[id] = this;
    tests[test] = id;
  }

  int get a => tests["a"]!;
  /// b为空代表空白
  int? get b => tests["b"];

  static final Map<int, RPartialTerrain> _idMap = {};

  /// 根据terrain名字，可以查找到相关数据
  static final Map<String, RPartialTerrain> _allTerrains = {};

  bool _sameTerrain(int tileId) {
    return _idMap[tileId] == this;
  }


  static const _tblr = [1, 3, 4, 6];
  static const _includedCorner = [
    Tuple3(1, 3, 0),
    Tuple3(1, 4, 2),
    Tuple3(3, 6, 5),
    Tuple3(4, 6, 7),
  ];

  int? correct(List<int> list8, int id) {
    if (id == b) {
      return b!;
    }
    List<int> result = [];
    List<bool> bools = List.generate(
      8,
      (index) =>
          _sameTerrain(list8[index]) &&
          collection[list8[index]]!.codeUnitAt(0) != 'b'.codeUnitAt(0),
    );
    for (final idx in _tblr) {
      if (bools[idx]) {
        result.add(idx);
      }
    }
    // 上下左右没有连接
    if (result.isEmpty) {
      return a;
    }
    if (terrainType == TerrainType.corner) {
      for (final tuple in _includedCorner) {
        if (bools[tuple.item1] && bools[tuple.item2] && bools[tuple.item3]) {
          result.add(tuple.item3);
        }
      }
    }
    final testResult = (result..sort()).map((e) => e + 1).join('');
    final resultId = tests[testResult];
    return resultId;
  }

  emit(List<int> list) {
    final testResult = list.join('');
    final resultId = tests[testResult];
    return resultId ?? a;
  }

  static RPartialTerrain? getTerrainById(int id) {
    return _idMap[id];
  }
}

enum TerrainType {
  corner,
  edge,
}

TerrainType getTerrainType(String name) {
  switch(name) {
    case 'corner': return TerrainType.corner;
    case 'edge': return TerrainType.edge;
    default: return TerrainType.edge;
  }
}