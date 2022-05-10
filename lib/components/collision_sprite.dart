import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:game/common/geometry/polygon.dart';
import 'package:game/common/geometry/rectangle.dart';
import 'package:game/common/geometry/shape.dart';
import 'package:game/game.dart';

class ShapeSprite extends SpriteComponent {
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
      // 是否多边形
      shape = MyPolygonShape(
        relation!
            .map(
              (e) => e.clone()
                ..multiply(size / 2)
                ..add(size / 2),
            )
            .toList(growable: false),
      );
    } else {
      shape = MyRectangleShape(size);
    }
  }
  List<Vector2>? relation;

  late MyShape shape;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    shape.render(
      canvas,
      Paint()..color = const Color(0x55ffffff),
    );
  }
}

class CoverShapeSprite extends ShapeSprite with HasGameRef<MyGame> {
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
    checkCover();
  }

  void checkCover() {
    final isIntersectOrContain =
        hitBox.aabb.intersectsWithAabb2(gameRef.player.hitbox.aabb);
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
