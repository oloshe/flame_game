import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:game/common.dart';
import 'package:game/common/base/coord.dart';
import 'package:game/pages/map_editor/map_editor.dart';
import 'package:game/respect/index.dart';
import 'package:provider/provider.dart';

class MapEditorProvider with ChangeNotifier {
  /// 当前选中 tile
  int? currTileId;

  /// 地图数据
  late RMap rMap;

  /// 地图宽度
  int get width => rMap.width;

  /// 地图高度
  int get height => rMap.height;

  /// 当前选中区域 根据tile大小不同
  Rect? currRect;
  Coord? currPos;

  /// 标记层级版本用于更新
  UniqueKey layersVersion = UniqueKey();

  String? currLayerName;

  MapEditorProvider() {
    final layer1 = 'layer'.lang.args({"layer": 1});
    final layer2 = 'layer'.lang.args({"layer": 2});
    const w = 20;
    const h = 20;
    rMap = RMap(width: w, height: h, layers: {
      layer1: _createLayer(1, w, h, 1),
      layer2: _createLayer(2, w, h, 0),
    });
    currLayerName = layer1;
  }

  /// 修改图层名字
  setCurrLayerName(String name) {
    if (currLayerName != name) {
      currLayerName = name;
      notifyListeners();
    }
  }

  /// 填充图层
  fillCurrLayer() {
    if (currLayerName != null) {
      if (currTileId != null) {
        rMap.layers[currLayerName]?.fill(currTileId!);
        layersVersion = UniqueKey();
        notifyListeners();
      } else {
        Fluttertoast.showToast(msg: 'fillEmpty'.lang);
      }
    } else {
      Fluttertoast.showToast(msg: 'noLayer'.lang);
    }
  }

  bool? get currLayerVisible {
    return rMap.layers[currLayerName]?.visible;
  }

  /// 隐藏
  setCurrVisibility() {
    if (currLayerName != null) {
      if (rMap.layers.containsKey(currLayerName)) {
        final layer = rMap.layers[currLayerName]!;
        layer.visible = !layer.visible;
        layersVersion = UniqueKey();
        notifyListeners();
      }
    }
  }

  setTileId(int? id) {
    if (currTileId != id) {
      currTileId = id;
    } else {
      currTileId = null;
    }
    notifyListeners();
  }

  setSize(int w, int h) {
    if (width != w || height != h) {
      rMap.apply(w, h);
      notifyListeners();
    }
  }

  addLayer(String name) {
    if (rMap.layers.length > 10) {
      Fluttertoast.showToast(msg: 'layerMax'.lang);
      return;
    }
    final sureName = _checkLayerNameNoRepeat(name);
    rMap.layers[sureName] = _createLayer(rMap.layers.length + 1, width, height);
    currLayerName ??= sureName; // 如果没有层就默认选中该层
    notifyListeners();
    Fluttertoast.showToast(msg: 'layerAdded'.lang);
  }

  void deleteLayer(String name) {
    if (rMap.layers.containsKey(name)) {
      // 记录旧的下标
      final oldIndex = rMap.layerList.indexWhere((e) => e.key == name);
      rMap.layers.remove(name);
      Fluttertoast.showToast(msg: 'layerDeleted'.lang);
      if (currLayerName == name) {
        // 改变当前选择name
        // 使用oldIndex指向的那个name，如果不存在...
        if (rMap.layers.isNotEmpty) {
          if (oldIndex >= rMap.layers.length) {
            currLayerName = rMap.layerList.last.key;
          } else {
            final newCurrName = rMap.layerList[oldIndex].key;
            currLayerName = newCurrName;
          }
        } else {
          currLayerName = null;
        }
      }
      notifyListeners();
    }
  }

  /// 确保名字不重复
  String _checkLayerNameNoRepeat(String name) {
    var sureName = name;
    var index = 1;

    /// 确保名字不重复
    while (rMap.layers.containsKey(sureName)) {
      sureName = "$name$index";
      index += 1;
    }
    return sureName;
  }

  /// 重命名图层
  renameLayer(String? oldName, String newName) {
    if (rMap.layers.containsKey(oldName)) {
      final sureName = _checkLayerNameNoRepeat(newName);
      final tempData = rMap.layers.remove(oldName);
      assert(tempData != null);
      rMap.layers[sureName] = tempData!;
      if (currLayerName == oldName) {
        currLayerName = sureName;
      }
      notifyListeners();
    }
  }

  RMapLayerData _createLayer(int index, int w, int h, [int? fill]) {
    return RMapLayerData    (
      index: index,
      matrix: List.generate(
        h,
        (_) => List.generate(w, (_) => fill ?? RMapGlobal.emptyTile),
      ),
    );
  }

  paintCell(int x, int y, [int? _id]) {
    int? id = _id ?? currTileId;
    Rect? newRect;
    final len = MapEditor.len;
    final selectId = id ?? rMap.getMatrix(currLayerName, x, y);
    if (selectId != null) {
      final tile = R.getTileById(selectId);
      final w = tile?.size.x ?? 1;
      final h = tile?.size.y ?? 1;
      newRect = Rect.fromLTWH(x * len, y * len, w * len, h * len);
    } else {
      newRect = Rect.fromLTWH(x * len, y * len, len, len);
    }
    currRect = newRect;
    currPos = Coord(x, y);
    if (id != null) {
      if (currLayerName != null) {
        rMap.setMatrix(currLayerName!, x, y, id);
        layersVersion = UniqueKey();
      }
    }
    notifyListeners();
  }

  /// 删除当前选中的
  deleteCurr() {
    if (currLayerName != null) {
      if (currPos != null) {
        paintCell(currPos!.x, currPos!.y, RMapGlobal.emptyTile);
      }
    }
  }
}

extension MapEditorProviderExt on BuildContext {
  MapEditorProvider get editor => read<MapEditorProvider>();
}
