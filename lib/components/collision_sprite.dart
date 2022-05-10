import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:game/common.dart';
import 'package:game/common/geometry/polygon.dart';
import 'package:game/common/geometry/rectangle.dart';
import 'package:game/common/geometry/shape.dart';
import 'package:game/common/mixins/custom_collision.dart';
import 'package:game/game.dart';

class ShapeSprite extends SpriteComponent with HasMyShape {
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
      _shape =
          MyPolygonShape.relative(relation!, size: size, position: position);
    } else {
      _shape = MyRectangleShape(size, position: position);
    }
  }
  List<Vector2>? relation;

  late MyShape _shape;

  @override
  MyShape get shape => _shape;
}

class CoverShapeSprite extends ShapeSprite
    with HasGameRef<MyGame>, MyShapeCoverDelegate {
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

  RTileCoverData cover;

  late final MyPolygonShape coverPolygonShape;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
  }

  @override
  MyRectangleShape createShape() {
    return MyRectangleShape.percentage(
      cover,
      size: size,
      position: position,
    );
  }

  @override
  MyRectangleShape get targetShape => gameRef.player.shape;
}
