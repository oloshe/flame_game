import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';

class TileHitbox extends PositionComponent {
  TileHitbox({
    required this.vectors,
    required Vector2 size,
  }) : super(size: size);

  List<Vector2>? vectors;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    final hitBoxPaint = BasicPalette.white.paint()
      ..style = PaintingStyle.stroke;
    ShapeHitbox box;
    if (vectors != null) {
      // 是否多边形
      box = PolygonHitbox.relative(
        vectors!,
        parentSize: size,
        anchor: Anchor.center,
      );
    } else {
      box = RectangleHitbox();
    }
    box.paint = hitBoxPaint;
    box.renderShape = true;
    add(box);
  }
}
