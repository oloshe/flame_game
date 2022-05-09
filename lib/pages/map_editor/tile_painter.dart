import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:game/pages/map_editor/map_editor.dart';

class TilePainter extends CustomPainter {
  final bool selected;
  final Sprite? sprite;
  final Vector2 tileSize;
  final double? unitSize;
  static final Paint painter = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  TilePainter({
    required this.selected,
    required this.sprite,
    required this.tileSize,
    this.unitSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (sprite != null) {
      final _size = unitSize ?? MapEditor.len;
      sprite!.render(
        canvas,
        size: Vector2(_size * tileSize.x, _size * tileSize.y),
      );
      if (selected) {
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height),
          painter,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
