import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:game/common/base/dynamic_priority.dart';
import 'package:game/common/utils/dev_tool.dart';
import 'package:game/components/collision_sprite.dart';

abstract class MovableHitboxComponent extends PositionComponent
    with CollisionCallbacks, DynamicPriorityComponent {
  final ShapeHitbox hitbox;
  MovableHitboxComponent(this.hitbox) : super(anchor: Anchor.center);

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
      // 只判断hitbox是否相撞
      if (other is ShapeSprite) {
        _correct(intersectionPoints);
      } else if (other is MovableHitboxComponent) {
        _correct(intersectionPoints);
      }
    }
  }

  void _correct(Set<Vector2> intersectionPoints) {
    // 交点中间点
    final mid = (intersectionPoints.first + intersectionPoints.last) / 2;
    final collisionNormal = hitbox.absoluteCenter - mid;
    final separationDistance = (hitbox.size.x / 2) - collisionNormal.length;
    position += collisionNormal.normalized() * separationDistance;
  }

  @override
  void onMount() {
    final game = findGame();
    if (game != null && game is AllMovable) {
      game.allMovable.add(this);
    }
    super.onMount();
  }

  @override
  void onRemove() {
    final game = findGame();
    if (game != null && game is AllMovable) {
      game.allMovable.remove(this);
    }
    super.onRemove();
  }
}

mixin AllMovable on FlameGame {
  Set<MovableHitboxComponent> allMovable = {};
}
