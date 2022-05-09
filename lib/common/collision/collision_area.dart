import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';
import 'package:game/common/geometry/circle.dart';
import 'package:game/common/geometry/polygon.dart';
import 'package:game/common/geometry/rectangle.dart';
import 'package:game/common/geometry/shape.dart';

Paint _paintCollision = Paint();

class CollisionArea {
  final MyShape shape;
  final Vector2? align;

  CollisionArea(this.shape, {this.align});

  CollisionArea.rectangle({
    required Vector2 size,
    Vector2? align,
  })  : shape = RectangleShape(size),
        align = align ?? Vector2.zero();

  CollisionArea.circle({
    required double radius,
    Vector2? align,
  })  : shape = CircleShape(radius),
        align = align ?? Vector2.zero();

  CollisionArea.polygon({
    required List<Vector2> points,
    Vector2? align,
  })  : shape = MyPolygonShape(points),
        align = align ?? Vector2.zero();

  void updatePosition(Vector2 position) {
    shape.position = Vector2(
      position.x + (align?.x ?? 0.0),
      position.y + (align?.y ?? 0.0),
    );
  }

  void render(Canvas c, Color color, {Paint? overridePaint}) {
    shape.render(c, (overridePaint ?? _paintCollision)..color = color);
  }

  bool verifyCollision(CollisionArea other) {
    return shape.isCollision(other.shape);
  }

  bool verifyCollisionSimulate(Vector2 position, CollisionArea other) {
    MyShape? shapeAux;
    if (shape is CircleShape) {
      shapeAux = CircleShape(
        (shape as CircleShape).radius,
      );
    } else if (shape is RectangleShape) {
      shapeAux = RectangleShape(
        Vector2(
          (shape as RectangleShape).rect.width,
          (shape as RectangleShape).rect.height,
        ),
      );
    } else if (shape is MyPolygonShape) {
      shapeAux = MyPolygonShape(
        (shape as MyPolygonShape).relativePoints,
      );
    }

    shapeAux?.position = Vector2(
      position.x + (align?.x ?? 0.0),
      position.y + (align?.y ?? 0.0),
    );
    return shapeAux?.isCollision(other.shape) ?? false;
  }

  Rect get rect {
    if (shape is CircleShape) {
      return (shape as CircleShape).rect.rect;
    }

    if (shape is RectangleShape) {
      return (shape as RectangleShape).rect;
    }

    if (shape is MyPolygonShape) {
      return (shape as MyPolygonShape).rect.rect;
    }

    return Rect.zero;
  }
}
