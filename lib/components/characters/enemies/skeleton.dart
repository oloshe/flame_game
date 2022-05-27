import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:game/common/mixins/hitbox_mixin.dart';
import 'package:game/components/characters/enemy.dart';
import 'package:game/components/respect_map.dart';
import 'package:game/games/game.dart';
import 'package:game/respect/index.dart';

enum SkeletonStatus {
  idle,
  running,
  attack,
  hurt,
  die,
}

class Skeleton extends Enemy with HasGameRef<MyGame>, HasHitbox {
  Skeleton(RTileObject tileObject)
      : super(
          tileObject,
          CircleHitbox.relative(
            0.18,
            parentSize: RespectMap.characterBase,
            anchor: Anchor.center,
            position: Vector2.zero(),
          ),
        );

  @override
  PositionComponent get target => gameRef.player;

  @override
  double get speed => statusComp.current == SkeletonStatus.attack ? 0 : 80;

  // @override
  // double get sensingDistance => 0;

  @override
  List<Enum> allStatusEnums = SkeletonStatus.values;

  @override
  Enum initialStatusEnum = SkeletonStatus.idle;

  @override
  Set<Enum>? get removeOnFinish => {SkeletonStatus.die};

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    statusComp.animations?[SkeletonStatus.hurt]!.onComplete = onHurtCompleted;
    statusComp.animations?[SkeletonStatus.attack]!.onComplete =
        onAttackCompleted;
    statusComp.animations?[SkeletonStatus.die]!.onComplete = () {
      removeFromParent();
    };
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
    }
  }

  void onAttackCompleted() {
    statusComp.animation!.reset();
    statusComp.current = SkeletonStatus.idle;
  }

  @override
  void hurt() {
    if (statusComp.current == SkeletonStatus.attack) {
      statusComp.animation!.reset();
    }
    statusComp.current = SkeletonStatus.hurt;
    super.hurt();
  }

  void onHurtCompleted() {
    statusComp.animation!.reset();
    statusComp.current = SkeletonStatus.idle;
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
    }
  }
}
