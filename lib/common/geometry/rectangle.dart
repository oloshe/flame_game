import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:game/common.dart';
import 'package:game/common/geometry/shape.dart';

class MyRectangleShape extends MyShape {
  Rect _rect;
  late Vector2 leftTop;
  late Vector2 rightTop;
  late Vector2 rightBottom;
  late Vector2 leftBottom;

  MyRectangleShape(Vector2 size,
      {Vector2? position, Anchor anchor = Anchor.topLeft})
      : _rect = Rect.fromLTWH(
          position?.x ?? 0,
          position?.y ?? 0,
          size.x,
          size.y,
        ),
        super(position ?? Vector2.zero()) {
    _updateExtremities(this.position);
  }

  MyRectangleShape.percentage(
    RTileCoverData coverData, {
    required Vector2 size,
    Vector2? position,
    Anchor anchor = Anchor.topLeft,
  }) : this(
          coverData.size.clone()..multiply(size),
          position: position,
          anchor: anchor,
        );

  @override
  set position(Vector2 value) {
    super.position = value;
    _updateExtremities(value);
  }

  void _updateExtremities(Vector2 value) {
    _rect = Rect.fromLTWH(
      value.x,
      value.y,
      _rect.width,
      _rect.height,
    );
    leftTop = _rect.topLeft.toVector2();
    rightTop = _rect.topRight.toVector2();
    rightBottom = _rect.bottomRight.toVector2();
    leftBottom = _rect.bottomLeft.toVector2();
  }

  bool overlaps(MyRectangleShape other) {
    return rect.overlaps(other.rect);
  }

  // MyRectangleShape clone([Vector2? offset]) {
  //   final ret = MyRectangleShape.raw(
  //     _rect,
  //     leftTop: leftTop,
  //     rightTop: rightTop,
  //     rightBottom: rightBottom,
  //     leftBottom: leftBottom,
  //   );
  //   if (offset != null) {
  //     ret._updateExtremities(offset);
  //   }
  //   return ret;
  // }

  Rect get rect => _rect;

  double get height => _rect.height;
  double get width => _rect.width;
  double get left => _rect.left;
  double get top => _rect.top;
  double get right => _rect.right;
  double get bottom => _rect.bottom;

  @override
  void render(Canvas canvas, [Paint? paint]) {
    canvas.drawRect(rect, paint ?? MyShape.paint);
  }

  @override
  String toString() {
    return 'Rectangle:$rect';
  }
}
