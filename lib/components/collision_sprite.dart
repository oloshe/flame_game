import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';

class CollisionSprite extends SpriteComponent with CollisionCallbacks {
  CollisionSprite(
    Sprite sprite, {
    Vector2? size,
    Vector2? position,
    int? priority,
  }) : super(
          sprite: sprite,
          size: size,
          position: position,
          priority: priority,
        );

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    final hitBoxPaint = BasicPalette.white.paint()
      ..style = PaintingStyle.stroke;
    add(
      PolygonComponent.relative(
        [
          Vector2(-1, 1),
          Vector2(1, 1),
          Vector2(1, -1),
          Vector2(-1, -1),
        ],
        parentSize: size,
      )
        ..paint = hitBoxPaint
        ..renderShape = true,
    );
    add(RectangleHitbox());
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
  }
}
