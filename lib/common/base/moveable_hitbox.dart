import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:game/common/base/dynamic_priority.dart';
import 'package:game/common/utils/dev_tool.dart';
import 'package:game/components/collision_sprite.dart';
import 'package:game/respect/index.dart';

abstract class MovableHitboxComponent<T extends Enum> extends PositionComponent
    with CollisionCallbacks, DynamicPriorityComponent {
  /// 碰撞题
  final ShapeHitbox hitbox;

  /// Tile对象
  final RTileObject tileObject;

  /// 动作状态组件
  late SpriteAnimationGroupComponent<T> statusComp;

  MovableHitboxComponent(
    this.tileObject,
    this.hitbox,
  ) : super(anchor: Anchor.center);

  List<T> get allStatusEnums;
  T get initialStatusEnum;
  Set<T>? removeOnFinish;

  @override
  Future<void>? onLoad() async {
    statusComp = await tileObject.buildAnimationGroup<T>(
      allValues: allStatusEnums,
      initialValue: initialStatusEnum,
      removeOnFinish: removeOnFinish,
    );
    await add(statusComp);

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

  // @override
  // void onMount() {
  //   final game = findGame();
  //   if (game != null && game is AllMovable) {
  //     game.allMovable.add(this);
  //   }
  //   super.onMount();
  // }

  // @override
  // void onRemove() {
  //   final game = findGame();
  //   if (game != null && game is AllMovable) {
  //     game.allMovable.remove(this);
  //   }
  //   super.onRemove();
  // }
}

// mixin AllMovable on FlameGame {
//   Set<MovableHitboxComponent> allMovable = {};
// }