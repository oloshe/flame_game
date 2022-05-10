import 'package:flame/extensions.dart';
import 'package:flutter/widgets.dart';
import 'package:game/common/geometry/shape_collision.dart';

abstract class MyShape {
  static final Paint paint = Paint()
    ..color = const Color(0x55ffffff)
    ..style = PaintingStyle.fill;

  Vector2 _position;

  MyShape(Vector2 position) : _position = position;

  // ignore: unnecessary_getters_setters
  set position(Vector2 value) {
    _position = value;
  }

  // ignore: unnecessary_getters_setters
  Vector2 get position => _position;

  void render(Canvas canvas, [Paint? paint]);

  bool isCollision(MyShape b) {
    // print('$this\b$b');
    return ShapeCollision.isCollision(this, b);
  }
}

class ShapeMgr {
  ShapeMgr._();

  static final Set<MyShape> _renderList = {};
  static Set<MyShape> get renderList => _renderList;

  static final Set<MyShape> _coverList = {};
  static Set<MyShape> get coverList => _coverList;

  static init() {
    _renderList.clear();
    _coverList.clear();
  }

  static MyShape createShape(MyShape shape) {
    renderList.add(shape);
    return shape;
  }

  static void dropShape(MyShape shape) {
    renderList.remove(shape);
  }

  static MyShape createCoverShape(MyShape shape) {
    renderList.add(shape);
    coverList.add(shape);
    return shape;
  }
  static void dropCoverShape(MyShape shape) {
    renderList.remove(shape);
    coverList.remove(shape);
  }
}