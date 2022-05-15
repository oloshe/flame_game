import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:game/common.dart';
import 'package:game/pages/map_editor/map_editor.dart';

class TilePainter extends CustomPainter {
  final bool selected;
  final RTileData tile;
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

    if (tile.isCombine) {
      final tileList = tile.getCombinedTiles().toList(growable: false).reversed;
      for(final _tile in tileList) {
        final sprite = MapEditor.spriteCached[_tile.id];
        sprite!.render(
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
    }

    final sprite = MapEditor.spriteCached[tile.id];
    sprite!.render(
      canvas,
      size: Vector2(_size * tile.size.x, _size * tile.size.y),
    );
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
