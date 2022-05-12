import 'package:flame/components.dart';
import 'package:game/common.dart';
import 'package:game/components/enemies/enemy.dart';
import 'package:game/components/respect_map.dart';
import 'package:game/components/characters/player.dart';
import 'package:game/games/game.dart';

class Skeleton extends PositionComponent with Enemy, HasGameRef<MyGame> {
  /// 动作状态组件
  late SpriteAnimationGroupComponent<SkeletonStatus> statusComp;

  @override
  Player get target => gameRef.player;

  @override
  double get sensingDistance => 200;

  @override
  double get speed => statusComp.current == SkeletonStatus.attack ? 0 : 80;

  @override
  double get attackDistance => 30;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    final animations = await R.createAnimations(
      SkeletonStatus.values,
      R.animations.skeleton,
    );

    // XXX
    final srcSize =
        R.getImageData(R.animations.skeleton).srcSize ?? RespectMap.srcBase;

    statusComp = SpriteAnimationGroupComponent(
        animations: animations,
        current: SkeletonStatus.idle,
        position: Vector2.zero(),
        size: srcSize * RespectMap.scaleFactor,
        anchor: Anchor.center,
        removeOnFinish: {
          SkeletonStatus.die: true,
        });
    add(statusComp);
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
