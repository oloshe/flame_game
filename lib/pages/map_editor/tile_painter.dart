import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:game/pages/map_editor/map_editor.dart';
import 'package:game/respect/index.dart';

class TilePainter extends CustomPainter {
  final bool selected;
  final RCombine tile;
  final double? unitSize;
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
    final _size = unitSize ?? MapEditor.len;

    final tileList = tile.getPicTiles();
    if (tile.id == 50) {
      print(tileList.map((e) => e.id));
    }
    for (final _tile in tileList) {
      final sprite = _tile.getSprite();
      sprite.render(
        canvas,
        size: Vector2(_size * _tile.size.x, _size * _tile.size.y),
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
