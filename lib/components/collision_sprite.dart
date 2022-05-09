import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/cupertino.dart';
import 'package:forge2d/src/dynamics/body.dart';
import 'package:game/components/tile_hitbox.dart';
import 'package:game/game.dart';

class BodySprite extends BodyComponent {
  BodySprite(
    this.sprite, {
    required this.size,
    this.position,
    this.relation,
    int? priority,
  }) : super(priority: priority);

  Sprite sprite;
  Vector2 size;
  Vector2? position;

  List<Vector2>? relation;

  late SpriteComponent spriteComp;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    spriteComp = SpriteComponent(
      sprite: sprite,
      size: size,
      position: position,
      priority: priority,
    );
    add(spriteComp);
    position = position;
    // add(TileHitbox(vectors: relation, size: size));
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.static,
    );
    final body = world.createBody(bodyDef);
    // 碰撞体
    if (relation != null) {
      final shape = PolygonShape();

      shape.set(relation!);

      final fixtureDef = FixtureDef(
        shape,
        userData: this, // To be able to determine object in collision
        restitution: 0.4,
        density: 1.0,
        friction: 0.5,
      );
      body.createFixture(fixtureDef);
    }
    return body;
  }
}

class CoverCollisionSprite extends BodySprite {
  CoverCollisionSprite(
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

  List<Vector2> cover;
  late final PolygonHitbox hitBox;
  bool _isCover = false;

  int? oldP;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final hitBoxPaint = BasicPalette.green.paint()
      ..style = PaintingStyle.stroke;

    hitBox = PolygonHitbox.relative(
      cover,
      parentSize: size,
      anchor: Anchor.center,
    );
    if (MyGame.showHitbox) {
      hitBox
        ..paint = hitBoxPaint
        ..renderShape = true;
    }
    spriteComp.add(hitBox);
  }

  @override
  void update(double dt) {
    super.update(dt);
    checkCover();
  }

  void checkCover() {
    /// 是否香蕉或者包含
    final isIntersectOrContain =
        hitBox.aabb.containsAabb2((gameRef as MyGame).player.hitBox.aabb) ||
            hitBox.collidingWith((gameRef as MyGame).player.hitBox);
    if (_isCover != isIntersectOrContain) {
      _isCover = isIntersectOrContain;
      if (isIntersectOrContain) {
        oldP = priority;
        spriteComp.setOpacity(0.9);
        priority = 200;
      } else {
        setOpacity(1);
        priority = oldP!;
      }
    }
  }
}
