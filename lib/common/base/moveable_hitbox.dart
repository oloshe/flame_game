import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:game/common/mixins/custom_collision.dart';
import 'package:game/common/utils/dev_tool.dart';

abstract class MoveableHitboxComponent extends PositionComponent
    with CollisionCallbacks {
  final ShapeHitbox hitbox;
  MoveableHitboxComponent(this.hitbox) : super(anchor: Anchor.center);

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    if (DevTool.showMovableDebug.isDebug) {
      hitbox.debugMode = true;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (intersectionPoints.length == 2) {
      // 交点中间点
      final mid = (intersectionPoints.first + intersectionPoints.last) / 2;
      final collisionNormal = hitbox.absoluteCenter - mid;
      final separationDistance = (hitbox.size.x / 2) - collisionNormal.length;
      position += collisionNormal.normalized() * separationDistance;
    }
  }
}
