part of '../../common.dart';

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
}

typedef LayerForEachFunction = FutureOr<void> Function(RMapLayerData);

class RMapLayerData {
  /// 层级
  final int index;
  final bool obj;
  final List<List<int>> matrix;
  bool visible;

  RMapLayerData({
    required this.index,
    required this.obj,
    required this.matrix,
  }): visible = true;


  void _fill(int? fill, [bool emptyWhenNull = false]) {
    if (fill != null || emptyWhenNull) {
      final _fill = fill ?? RMapGlobal.emptyTile;
      for(var i = 0; i < matrix.length; i++) {
        for(var j = 0; j < matrix[i].length; j++) {
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
    List<List<int>> matrix = List.generate(
        height, (_) => List.filled(width, RMapGlobal.emptyTile));

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
      obj: json['obj'] ?? false,
      matrix: matrix,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      "index": index,
      "obj": obj,
      "matrix": matrix,
    };
    return result;
  }
}