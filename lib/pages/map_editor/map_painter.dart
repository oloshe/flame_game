import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:game/common.dart';
import 'package:game/common/base/coord.dart';
import 'package:game/components/respect_map.dart';
import 'package:game/pages/map_editor/map_editor.dart';

class MapPainter extends CustomPainter {
  final RMapLayerData layerData;

  /// 表示整个图层的宽度和高度
  final int width;
  final int height;

  MapPainter(this.layerData, this.width, this.height);

  @override
  void paint(Canvas canvas, Size size) {
    drawSingleLayer(canvas, layerData);
  }

  /// 绘制单个图层
  void drawSingleLayer(Canvas canvas, RMapLayerData? layer) {
    if (layer == null || layer.visible == false) {
      return;
    }
    final len = MapEditor.len;
    Map<String, SpriteBatch> batch = {};
    _eachCell(width, height, (x, y) {
      final id = layer.matrix[y][x];
      if (id != RMapGlobal.emptyTile) {
        final tileData = R.getTileById(id);
        if (tileData != null) {
          final pic = tileData.pic;
          final sp = MapEditor.spriteCached[id]!;
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
            offset: Vector2(len * x, len * y),
          );
        } else {
          print('error');
        }
      }
    });
    for (final item in batch.entries) {
      item.value.render(canvas);
    }
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
    final len = MapEditor.len;
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
  static final Paint painter2 = Paint()
    ..color = Colors.orange
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;
  @override
  void paint(Canvas canvas, Size size) {
    final len = MapEditor.len;
    // 绘制选中
    canvas.drawRect(
      Rect.fromLTWH(coord.x * len, coord.y * len, len, len),
      painter2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

void _eachCell(int width, int height, void Function(int x, int y) func) {
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      func.call(x, y);
    }
  }
}
