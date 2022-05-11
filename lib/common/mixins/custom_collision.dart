import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:game/common/geometry/rectangle.dart';
import 'package:game/common/geometry/shape.dart';

mixin UseMyShapeMgr on Component {
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    for (final s in ShapeMgr.renderList) {
      s.render(canvas);
    }
  }
}

mixin HasMyShape on PositionComponent {
  MyShape get shape;

  @override
  void onMount() {
    // ShapeMgr.createShape(shape);
    super.onMount();
  }

  @override
  void onRemove() {
    // ShapeMgr.dropShape(shape);
    super.onMount;
  }
}

mixin MyShapeCoverDelegate on PositionComponent implements HasPaint {
  late final MyRectangleShape coverShape;
  MyRectangleShape get targetShape;
  bool isCover = false;
  int? oldP;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    coverShape = createShape();
    ShapeMgr.createCoverShape(coverShape);
  }

  @override
  void onRemove() {
    ShapeMgr.dropCoverShape(coverShape);
    super.onRemove();
  }

  MyRectangleShape createShape();

  @override
  @mustCallSuper
  void update(double dt) {
    super.update(dt);
    checkCover();
  }

  @mustCallSuper
  void checkCover() {
    final isIntersectOrContain = coverShape.overlaps(targetShape);
    if (isCover != isIntersectOrContain) {
      isCover = isIntersectOrContain;
      if (isIntersectOrContain) {
        oldP = priority;
        setOpacity(0.9);
        priority = 200;
      } else {
        setOpacity(1);
        priority = oldP!;
      }
    }
  }
}

class SingletonCollision extends PositionComponent with UseMyShapeMgr {}
