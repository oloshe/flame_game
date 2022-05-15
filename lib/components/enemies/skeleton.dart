import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:game/common.dart';
import 'package:game/common/base/moveable_hitbox.dart';
import 'package:game/common/mixins/custom_collision.dart';
import 'package:game/components/enemies/enemy.dart';
import 'package:game/components/respect_map.dart';
import 'package:game/games/game.dart';
import 'package:game/respect/index.dart';

class Skeleton extends MovableHitboxComponent
    with Enemy, HasGameRef<MyGame>, HasHitbox {
  Skeleton()
      : super(
          CircleHitbox.relative(
            0.18,
            parentSize: RespectMap.characterBase,
            anchor: Anchor.center,
            position: Vector2.zero(),
          ),
        );

  @override
  PositionComponent get target => gameRef.player;

  /// 动作状态组件
  late SpriteAnimationGroupComponent<SkeletonStatus> statusComp;

  @override
  double get speed => statusComp.current == SkeletonStatus.attack ? 0 : 80;

  // @override
  // double get sensingDistance => 0;

  @override
  Future<void>? onLoad() async {
    final animations = await R.createAnimations(
      SkeletonStatus.values,
      'skeleton',
    );

    // XXX
    final srcSize =
        R.getImageData('skeleton').srcSize ?? RespectMap.srcBase;

    statusComp = SpriteAnimationGroupComponent(
      animations: animations,
      current: SkeletonStatus.idle,
      position: Vector2.zero(),
      size: srcSize * RespectMap.scaleFactor,
      anchor: const Anchor(0.5, 0.83),
      removeOnFinish: {
        SkeletonStatus.die: true,
      },
    );
    await add(statusComp);

    await super.onLoad();
  }

  @override
  void flipHorizontal() {
    statusComp.scale.multiply(Vector2(-1, 1));
  }

  @override
  void idle() {
    if (statusComp.current != SkeletonStatus.attack) {
      statusComp.current = SkeletonStatus.idle;
    }
  }

  @override
  void move() {
    if (statusComp.current != SkeletonStatus.attack) {
      statusComp.current = SkeletonStatus.running;
    }
  }

  @override
  void attack() {
    if (statusComp.current != SkeletonStatus.attack) {
      statusComp.current = SkeletonStatus.attack;
      statusComp.animation!.onComplete = onAttackCompleted;
    }
  }

  void onAttackCompleted() {
    statusComp.animation!.reset();
    statusComp.current = SkeletonStatus.idle;
    statusComp.animation!.onComplete = null;
  }
}
