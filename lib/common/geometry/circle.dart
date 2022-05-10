import 'dart:ui';

import 'package:flame/extensions.dart';

import 'rectangle.dart';
import 'shape.dart';

class CircleShape extends MyShape {
  final double radius;
  final MyRectangleShape rect;
  Vector2 center;
  Offset offsetToDraw;

  CircleShape(this.radius, {Vector2? position})
      : center = (position ?? Vector2.zero()) + Vector2.all(radius),
        offsetToDraw = Offset((position ?? Vector2.zero()).x + radius,
            (position ?? Vector2.zero()).y + radius),
        rect = MyRectangleShape(
          Vector2(2 * radius, 2 * radius),
          position: position,
        ),
        super(position ?? Vector2.zero());

  @override
  set position(Vector2 value) {
    if (value != super.position) {
      super.position = value;
      rect.position = value;
      center = value + Vector2.all(radius);
      offsetToDraw = Offset(position.x + radius, position.y + radius);
    }
  }

  @override
  void render(Canvas canvas, [Paint? paint]) {
    canvas.drawCircle(
      Offset(position.x + radius, position.y + radius),
      radius,
      paint ?? MyShape.paint,
    );
  }
}
