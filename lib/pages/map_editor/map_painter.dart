import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:game/common.dart';
import 'package:game/pages/map_editor/map_editor.dart';

class MapPainter extends CustomPainter {

  final RMapLayerData layerData;

  final int width;
  final int height;

  MapPainter(this.layerData, this.width, this.height);

  @override
  void paint(Canvas canvas, Size size) {
    drawSingleLayer(canvas, layerData);
  }

  /// 绘制单个图层
  void drawSingleLayer(Canvas canvas, RMapLayerData? layer) {
    if (layer == null) {
      return;
    }
    const len = MapEditor.len2;
    _eachCell(width, height, (x, y) {
      final id = layer.matrix[y][x];
      if (id != RMapGlobal.emptyTile) {
        final tileData = R.getTileById(id);
        MapEditor.spriteCached[id]!.render(
          canvas,
          size: Vector2(
            len * (tileData?.size.x ?? 1),
            len* (tileData?.size.y ?? 1),
          ),
          position: Vector2(len * x, len * y),
        );
      }
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class MapGridPainter extends CustomPainter {

  final int width;
  final int height;

  MapGridPainter(this.width, this.height);

  static final Paint painter = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    const len = MapEditor.len2;
    // 绘制网格
    _eachCell(width, height, (x, y) {
      canvas.drawRect(Rect.fromLTWH(x * len, y * len, len, len), painter);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class CurrTilePainter extends CustomPainter {
  CurrTilePainter(this.coord);
  final Coord coord;
  static const len = MapEditor.len2;
  static final Paint painter2 = Paint()
    ..color = Colors.orange
    ..style = PaintingStyle.stroke;
  @override
  void paint(Canvas canvas, Size size) {
    const len = MapEditor.len2;
    // 绘制选中
    canvas.drawRect(
      Rect.fromLTWH(coord.x * len, coord.y * len, len, len),
      painter2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

}

void _eachCell(int width, int height, void Function(int x, int y) func) {
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      func.call(x, y);
    }
  }
}