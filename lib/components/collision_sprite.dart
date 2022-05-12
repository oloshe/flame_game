import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:game/common/mixins/custom_collision.dart';
import 'package:game/games/game.dart';

class ShapeSprite extends SpriteComponent with HasHitbox {
  ShapeSprite(
    Sprite sprite, {
    required Vector2 size,
    Vector2? position,
    int? priority,
    this.relation,
  }) : super(
          sprite: sprite,
          size: size,
          position: position,
          priority: priority,
        ) {
    if (relation != null) {
      hitbox = PolygonHitbox.relative(relation!, parentSize: size);
    } else {
      hitbox = RectangleHitbox(size: size);
    }
  }
  List<Vector2>? relation;

  @override
  late ShapeHitbox hitbox;
}

class CoverShapeSprite extends ShapeSprite with HasGameRef<MyGame>, CoverMixin {
  CoverShapeSprite(
    Sprite sprite, {
    required this.cover,
    required Vector2 size,
    Vector2? position,
    int? priority,
    List<Vector2>? relation,
  }) : super(
          sprite,
          size: size,
          position: position,
          priority: priority,
          relation: relation,
        );

  @override
  double cover;

  @override
  double get target => gameRef.player.position.y;
}
