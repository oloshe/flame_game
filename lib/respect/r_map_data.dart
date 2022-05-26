part of 'index.dart';

class RMapGlobal {
  static const _prefix = 'json/maps/';
  static const int emptyTile = 0;
  final Map<String, String> map;

  RMapGlobal({
    required this.map,
  });

  factory RMapGlobal.fromJson(Map<String, dynamic> json) {
    return RMapGlobal(
      map: Map.from(json['map']).map((key, value) => MapEntry(key, value)),
    );
  }

  static Future<RMapGlobal> fromFile() async {
    final json = await Flame.assets.readJson('json/map.json');
    return RMapGlobal.fromJson(json);
  }

  Future<RMap> loadMap(String name) async {
    final path = map[name]!;
    final json = await Flame.assets.readJson('$_prefix$path');
    return RMap.fromJson(json);
  }
}

class RMap {
  int width;
  int height;
  final Map<String, RMapLayerData> layers;

  /// 根据index升序排序
  List<MapEntry<String, RMapLayerData>> get layerList {
    final list = layers.entries.toList(growable: false);
    list.sort((a, b) => a.value.index - b.value.index);
    return list;
  }

  Vector2 get size => Vector2(width.toDouble(), height.toDouble());

  RMap({
    required this.width,
    required this.height,
    required this.layers,
  });

  factory RMap.fromJson(Map<String, dynamic> json) {
    int width = json['width'];
    int height = json['height'];
    return RMap(
      width: width,
      height: height,
      layers: Map.from(json['layers']).map(
        (key, value) =>
            MapEntry(key, RMapLayerData.fromJson(value, width, height)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "width": width,
      "height": height,
      "layers": layers.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  Future<void> forEachLayer(LayerForEachFunction action) async {
    final sortedList = layers.entries.toList(growable: false);
    sortedList.sort((a, b) => a.value.index - b.value.index);
    for (var _layer in sortedList) {
      await action(_layer.value);
    }
  }

  /// 修改长宽，强制修改每一个图层的矩阵，多的去掉，少的补充
  void apply(int w, int h, [int? fill]) {
    final _fill = fill ?? RMapGlobal.emptyTile;
    width = w;
    height = h;
    layers.forEach((key, layer) {
      List<List<int>> _rows = layer.matrix;
      final _rowCount = _rows.length;
      if (_rowCount > h) {
        _rows.removeRange(h, _rows.length);
      } else if (_rowCount < h) {
        _rows.add(List.generate(h - _rowCount, (index) => _fill));
      }

      for (final row in _rows) {
        final _columnCount = row.length;
        if (_columnCount > w) {
          row.removeRange(w, row.length);
        } else if (_columnCount < h) {
          row.addAll(List.generate(w - _columnCount, (index) => _fill));
        }
      }
    });
  }

  void setMatrixOld(String name, int x, int y, int id, [bool spread = true]) {
    final layer = layers[name];
    if (layer == null) {
      return;
    }
    if (!contains(x, y)) {
      return;
    }
    // 周围8个
    final list8 = layer._getSurrounding(x, y);
    final terrain = RPartialTerrain.getTerrainById(id);
    if (terrain != null) {
      layer.matrix[y][x] = terrain.correct(list8, id) ?? terrain.a;
    } else {
      layer.matrix[y][x] = id;
    }
    if (spread) {
      final dir = RMapLayerData.dir;
      final len = dir.length;
      for (var index = 0; index < len; index++) {
        final dx = dir[index].x + x;
        final dy = dir[index].y + y;
        setMatrixOld(name, dx, dy, list8[index], false);
      }
    }
  }

  /// [name] 图层名
  /// [auto] 判断是否手动触发，还是自动矫正
  void setMatrix(
    String name,
    SetMatrixAction action, {
    bool auto = false,
    void Function()? markAsFail,
    RPartialTerrain? originTerrain,
    void Function(int x, int y, int id)? setter,
  }) {
    final layer = layers[name];
    if (layer == null) {
      return;
    }
    final x = action.x;
    final y = action.y;
    final id = action.id;
    if (!contains(x, y)) {
      return;
    }
    final _setter = setter ??
        (int x, int y, int id) {
          _setMatrixUnsafe(layer.matrix, x, y, id);
        };
    // 周围8个
    final list8 = layer._getSurrounding(x, y);
    final terrain = RPartialTerrain.getTerrainById(id);
    bool fail = false;
    if (!auto) {
      final dir = RMapLayerData.dir;
      final len = dir.length;
      final tmp = layer.matrix[y][x];
      _setter(x, y, id);

      final List<SetMatrixAction> actions = [];
      for (var index = 0; index < len; index++) {
        final dx = dir[index].x + x;
        final dy = dir[index].y + y;
        setMatrix(name, SetMatrixAction(dx, dy, list8[index]),
            auto: true,
            originTerrain: terrain,
            markAsFail: () => fail = true,
            setter: (int x, int y, int id) {
              actions.add(SetMatrixAction(x, y, id));
              // _setter(x, y, id);
            });
      }
      if (!fail) {
        for (var ac in actions) {
          _setter(ac.x, ac.y, ac.id);
        }
      }
      _setter(x, y, tmp);
    } else {}
    if (terrain != null) {
      if (fail) {
        _setter(x, y, terrain.a);
      } else {
        final oldId = layer.matrix[y][x];
        final newId = terrain.correct(list8, id);
        if (newId == null) {
          _setter(x, y, oldId);
          markAsFail?.call();
        } else {
          _setter(x, y, newId);
        }
      }
    } else {
      _setter(x, y, id);
    }
  }

  void _setMatrixUnsafe(List<List<int>> matrix, int x, int y, int id) {
    matrix[y][x] = id;
  }

  int? getMatrix(String? name, int x, int y) {
    return layers[name]?.matrix.at(y)?.at(x);
  }

  /// 边界检查
  bool contains(int x, int y) {
    return x >= 0 && y >= 0 && x < width && y < height;
  }
}

typedef LayerForEachFunction = FutureOr<void> Function(RMapLayerData);

class RMapLayerData {
  /// 层级
  final int index;
  final List<List<int>> matrix;
  bool visible;

  RMapLayerData({
    required this.index,
    required this.matrix,
    this.visible = true,
  });

  static final List<Coord> dir = List.unmodifiable(const [
    Coord(-1, -1),
    Coord(0, -1),
    Coord(1, -1),
    Coord(-1, 0),
    Coord(1, 0),
    Coord(-1, 1),
    Coord(0, 1),
    Coord(1, 1),
  ]);

  List<int> _getSurrounding(int x, int y) {
    return List.generate(8, (index) {
      final dx = dir[index].x + x;
      final dy = dir[index].y + y;
      return matrix.at(dy)?.at(dx) ?? -1; // 不在矩阵范围内的负值为-1
    });
  }

  void _fill(int? fill, [bool emptyWhenNull = false]) {
    if (fill != null || emptyWhenNull) {
      final _fill = fill ?? RMapGlobal.emptyTile;
      for (var i = 0; i < matrix.length; i++) {
        for (var j = 0; j < matrix[i].length; j++) {
          matrix[i][j] = _fill;
        }
      }
    }
  }

  // 填充某一个tile
  void fill(int fill) {
    _fill(fill, false);
  }

  // 清空
  void clear() {
    _fill(null, true);
  }

  factory RMapLayerData.fromJson(
      Map<String, dynamic> json, int width, int height) {
    List<List<int>> matrix =
        List.generate(height, (_) => List.filled(width, RMapGlobal.emptyTile));

    List<dynamic> _rows = json['matrix'];
    final _height = _rows.length;
    for (var j = 0; j < _height && j < height; j++) {
      List<dynamic> _row = _rows[j];
      final _width = _row.length;
      for (var i = 0; i < _width && i < width; i++) {
        matrix[j][i] = _row[i];
      }
    }

    return RMapLayerData(
      index: json['index'],
      matrix: matrix,
      visible: json["visible"] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      "index": index,
      "matrix": matrix,
    };
    if (visible == false) {
      result["visible"] = visible;
    }
    return result;
  }
}

class SetMatrixAction extends Coord {
  final int id;
  SetMatrixAction(int x, int y, this.id) : super(x, y);
}
