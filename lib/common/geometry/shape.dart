import 'package:flame/extensions.dart';
import 'package:flutter/widgets.dart';
import 'package:game/common/geometry/shape_collision.dart';

abstract class MyShape {
  Vector2 _position;

  MyShape(Vector2 position) : _position = position;

  // ignore: unnecessary_getters_setters
  set position(Vector2 value) {
    _position = value;
  }

  // ignore: unnecessary_getters_setters
  Vector2 get position => _position;

  void render(Canvas canvas, Paint paint);

  bool isCollision(MyShape b) {
    return ShapeCollision.isCollision(this, b);
  }
}
