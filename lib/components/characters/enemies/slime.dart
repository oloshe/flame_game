import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:game/common/mixins/hitbox_mixin.dart';
import 'package:game/components/characters/enemy.dart';
import 'package:game/components/respect_map.dart';
import 'package:game/games/game.dart';
import 'package:game/respect/index.dart';

enum SlimeStatus {
  idle,
  running,
  attack,
  hurt,
  die,
}

class Slime extends Enemy with HasGameRef<MyGame>, HasHitbox {
  Slime(RTileObject tileObject)
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
  double get speed => statusComp.current == SlimeStatus.attack ? 0 : 30;

  // @override
  // double get sensingDistance => 0;

  @override
  List<Enum> allStatusEnums = SlimeStatus.values;

  @override
  Enum initialStatusEnum = SlimeStatus.idle;

  @override
  Set<Enum>? get removeOnFinish => {SlimeStatus.die};

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    statusComp.animations?[SlimeStatus.hurt]!.onComplete = onHurtCompleted;
    statusComp.animations?[SlimeStatus.attack]!.onComplete = onAttackCompleted;
    statusComp.animations?[SlimeStatus.die]!.onComplete = () {
      removeFromParent();
    };
  }

  @override
  void flipHorizontal() {
    statusComp.scale.multiply(Vector2(-1, 1));
  }

  @override
  void idle() {
    if (statusComp.current != SlimeStatus.attack) {
      statusComp.current = SlimeStatus.idle;
    }
  }

  @override
  void move() {
    if (statusComp.current != SlimeStatus.attack) {
      statusComp.current = SlimeStatus.running;
    }
  }

  @override
  void attack() {
    super.attack();
    if (statusComp.current != SlimeStatus.attack) {
      statusComp.current = SlimeStatus.attack;
    }
  }

  void onAttackCompleted() {
    statusComp.animation!.reset();
    statusComp.current = SlimeStatus.idle;
  }

  @override
  void hurt() {
    if (statusComp.current == SlimeStatus.attack) {
      statusComp.animation!.reset();
    }
    statusComp.current = SlimeStatus.hurt;
    super.hurt();
  }

  void onHurtCompleted() {
    statusComp.animation!.reset();
    statusComp.current = SlimeStatus.idle;
  }

  @override
  bool canMove() {
    return statusComp.current != SlimeStatus.hurt &&
        statusComp.current != SlimeStatus.attack &&
        statusComp.current != SlimeStatus.die;
  }

  @override
  void die() {
    if (statusComp.current != SlimeStatus.die) {
      statusComp.current = SlimeStatus.die;
    }
  }
}
