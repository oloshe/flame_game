
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:game/common.dart';
import 'package:game/pages/map_editor/map_editor.dart';

class MapPainter extends CustomPainter {
  final RMap mapData;
  final Paint painter = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke;

  MapPainter(this.mapData);

  @override
  void paint(Canvas canvas, Size size) {
    const len = MapEditor.len2;
    // 绘制网格
    _eachCell((x, y) {
      canvas.drawRect(Rect.fromLTWH(x * len, y * len, len, len), painter);
    });
    for (final _layer in mapData.layers.entries) {
      final layer = _layer.value;
      _eachCell((x, y) {
        final id = layer.matrix[y][x];
        if (id == RMapGlobal.emptyTile) {
          return;
        } else {
          MapEditor.spriteCached[id]!.render(
            canvas,
            size: Vector2(len, len),
            position: Vector2(len * x, len * y),
          );
          // canvas.drawImage(image, offset, paint)
        }
      });
    }
  }

  void _eachCell(void Function(int x, int y) func) {
    for (var y = 0; y < mapData.height; y++) {
      for (var x = 0; x < mapData.width; x++) {
        func.call(x, y);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}