part of '../index.dart';

/// 路径集合
class RTileTerrainSet {
  final String terrainName;
  final Map<int, String> tileIdTest;
  final Map<String, int> sets;
  int get a => sets["a"]!;
  int get b => sets["b"]!;
  RTileTerrainSet(this.terrainName)
      : sets = {},
        tileIdTest = {};

  addTerrain(
    RTileBase tileBase,
    Map<String, dynamic> json,
  ) {
    String test = json['test'];
    tileIdTest[tileBase.id] = test;
    sets[test] = tileBase.id;
  }

  bool _sameTileTerrain(int tileId) {
    return R.getTileById(tileId)?.terrain == terrainName;
  }

  TerrainCorrectResult terrainCorrect(List<int> list8, int id) {
    const tblr = [1, 3, 4, 6];
    const includedCorner = [
      Tuple3(1, 3, 0),
      Tuple3(1, 4, 2),
      Tuple3(3, 6, 5),
      Tuple3(4, 6, 7),
    ];
    List<int> result = [];
    List<Tuple2<int, int>> changedCoord = [];
    List<bool> bools = List.generate(
      8,
      (index) =>
          _sameTileTerrain(list8[index]) &&
          tileIdTest[list8[index]]!.codeUnitAt(0) != 'b'.codeUnitAt(0),
    );
    for (final idx in tblr) {
      if (bools[idx]) {
        changedCoord.add(RMapLayerData.dir[idx]);
        result.add(idx);
      }
    }
    if (result.isEmpty) {
      return TerrainCorrectResult(id == b ? b : a, a, changedCoord);
    }
    for (final tuple in includedCorner) {
      if (bools[tuple.item1] && bools[tuple.item2] && bools[tuple.item3]) {
        changedCoord.add(RMapLayerData.dir[tuple.item3]);
        result.add(tuple.item3);
      }
    }
    if (id == b) {
      return TerrainCorrectResult(b, a, changedCoord);
    }
    final testResult = (result..sort()).map((e) => e + 1).join('');
    // print('testResult = $testResult b=$b');
    final resultId = sets[testResult];
    return TerrainCorrectResult(resultId, resultId ?? id, changedCoord);
  }
}

class TerrainCorrectResult {
  final int? newId;
  final int nextId;
  bool get changed => newId != null;
  final List<Tuple2<int, int>> changedCoord;
  TerrainCorrectResult(this.newId, this.nextId, this.changedCoord);
  @override
  String toString() {
    return 'TerrainCorrectResult(newId = $newId, nextId = $nextId, $changedCoord)';
  }
}
