import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:game/components/tile_hitbox.dart';
import 'package:game/game.dart';

class HitboxSprite extends SpriteComponent {
  HitboxSprite(
    Sprite sprite, {
    Vector2? size,
    Vector2? position,
    int? priority,
    this.relation,
  }) : super(
          sprite: sprite,
          size: size,
          position: position,
          priority: priority,
        );
  List<Vector2>? relation;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    add(TileHitbox(vectors: relation, size: size));
  }
}

class CoverCollisionSprite extends HitboxSprite with HasGameRef<MyGame> {
  CoverCollisionSprite(
    Sprite sprite, {
    required this.cover,
    Vector2? size,
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

  List<Vector2> cover;
  late final PolygonHitbox hitBox;
  bool _isCover = false;

  int? oldP;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    final hitBoxPaint = BasicPalette.green.paint()
      ..style = PaintingStyle.stroke;
    hitBox = PolygonHitbox.relative(
      cover,
      parentSize: size,
      anchor: Anchor.center,
    )
      ..paint = hitBoxPaint
      ..renderShape = true;
    add(hitBox);
  }

  @override
  void update(double dt) {
    super.update(dt);
    var isIntersectOrContain =
        hitBox.aabb.containsAabb2(gameRef.player.hitBox.aabb);
    if (!isIntersectOrContain) {
      isIntersectOrContain = hitBox.collidingWith(gameRef.player.hitBox);
    }
    if (_isCover != isIntersectOrContain) {
      _isCover = isIntersectOrContain;
      if (isIntersectOrContain) {
        oldP = priority;
        setOpacity(0.9);
        priority = 200;
        // print(parent);
        // parent?.parent?.parent?.priority = 100;
      } else {
        setOpacity(1);
        priority = oldP!;
      }
    }
  }
}
