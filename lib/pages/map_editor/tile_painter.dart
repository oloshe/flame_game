import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:game/components/respect_map.dart';
import 'package:game/pages/map_editor/map_editor.dart';
import 'package:game/respect/index.dart';

class TilePainter extends CustomPainter {
  final bool selected;
  final RCombine tile;
  final Vector2? unitSize;
  static final Paint painter = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  TilePainter({
    required this.selected,
    required this.tile,
    this.unitSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final _size = unitSize ?? RespectMap.base;
    final tileList = tile.getPicTiles();
    for (final _tile in tileList) {
      final sprite = _tile.getDisplaySprite();
      print(sprite.srcPosition);
      sprite.render(
        canvas,
        size: _tile.displaySize,
      );
      if (selected) {
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height),
          painter,
        );
      }
    }
    if (selected) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        painter,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
