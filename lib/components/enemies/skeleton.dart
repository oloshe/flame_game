import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:game/common.dart';
import 'package:game/common/mixins/hitbox_mixin.dart';
import 'package:game/components/enemies/enemy.dart';
import 'package:game/components/respect_map.dart';
import 'package:game/games/game.dart';
import 'package:game/respect/index.dart';

class Skeleton extends Enemy with HasGameRef<MyGame>, HasHitbox {
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
    final srcSize = R.getImageData('skeleton').srcSize;

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
    super.attack();
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

  @override
  void hurt() {
    if (statusComp.current == SkeletonStatus.attack) {
      statusComp.animation!.reset();
    }
    statusComp.current = SkeletonStatus.hurt;
    statusComp.animation!.onComplete = onHurtCompleted;
    super.hurt();
  }

  void onHurtCompleted() {
    statusComp.animation!.reset();
    statusComp.current = SkeletonStatus.idle;
    statusComp.animation!.onComplete = null;
  }

  @override
  bool canMove() {
    return statusComp.current != SkeletonStatus.hurt &&
        statusComp.current != SkeletonStatus.attack &&
        statusComp.current != SkeletonStatus.die;
  }

  @override
  void die() {
    if (statusComp.current != SkeletonStatus.die) {
      statusComp.current = SkeletonStatus.die;
      statusComp.animation!.onComplete = () {
        removeFromParent();
      };
    }
  }
}
