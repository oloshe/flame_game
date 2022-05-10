import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:game/common/geometry/rectangle.dart';
import 'package:game/common/geometry/shape.dart';

class MyPolygonShape extends MyShape {
  final List<Vector2> relativePoints;
  final List<Vector2> points;
  final MyRectangleShape rect;
  MyPolygonShape(this.relativePoints, {Vector2? position})
      : assert(relativePoints.length > 2),
        points = _initPoints(relativePoints, position ?? Vector2.zero()),
        rect = _initRect(relativePoints, position ?? Vector2.zero()),
        super(position ?? Vector2.zero());

  MyPolygonShape.relative(
    Iterable<Vector2> relativePoints, {
    required Vector2 size,
    Vector2? position,
  }) : this(
          // position == null
          //     ? relativePoints
          //         .map((e) => e.clone()
          //           ..multiply(size / 2)
          //           ..add(size / 2))
          //         .toList(growable: false)
          //     : relativePoints
          //         .map((e) => e.clone()..multiply(size / 2)
          //         ..add(size / 2))
          //         .toList(growable: false),
          relativePoints
              .map((e) => e.clone()
                ..multiply(size / 2)
                ..add(size / 2))
              .toList(growable: false),
          position: position,
        );

  static List<Vector2> _initPoints(
    List<Vector2> relativePoints,
    Vector2 position,
  ) {
    final list = <Vector2>[];
    for (var i = 0; i < relativePoints.length; i++) {
      list.add(relativePoints[i] + position);
    }
    return list;
  }

  static MyRectangleShape _initRect(
    List<Vector2> relativePoints,
    Vector2 position,
  ) {
    double height = 0;
    double width = 0;
    for (var offset in relativePoints) {
      if (offset.x > width) {
        width = offset.x;
      }
      if (offset.y > height) {
        height = offset.y;
      }
    }

    return MyRectangleShape(Vector2(width, height), position: position);
  }

  @override
  set position(Vector2 value) {
    if (value != position) {
      super.position = value;

      rect.position = value;
      for (var i = 0; i < points.length; i++) {
        points[i] = relativePoints[i] + value;
      }
    }
  }

  @override
  void render(Canvas canvas, [Paint? paint]) {
    if (points.isNotEmpty) {
      final path = Path()..moveTo(points.first.x, points.first.y);
      for (var i = 1; i < points.length; i++) {
        path.lineTo(points[i].x, points[i].y);
      }
      path.lineTo(points.first.x, points.first.y);

      canvas.drawPath(path, paint ?? MyShape.paint);
    }
  }

  @override
  String toString() {
    return 'Polygon:($rect)';
  }
}
