
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:game/pages/map_editor/map_editor.dart';

class TilePainter extends CustomPainter {
  final bool selected;
  final Sprite? sprite;
  Paint painter = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  TilePainter(this.selected, this.sprite);

  @override
  void paint(Canvas canvas, Size size) {
    if (sprite != null) {
      sprite!.render(
        canvas,
        size: Vector2(MapEditor.len2, MapEditor.len2),
      );
      if (selected) {
        canvas.drawRect(
            Rect.fromLTWH(-1, -1, size.width, size.height), painter);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}