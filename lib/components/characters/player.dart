import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:game/common/base/moveable_hitbox.dart';
import 'package:game/common/mixins/custom_collision.dart';
import 'package:game/common/utils/dev_tool.dart';
import 'package:game/components/respect_map.dart';
import 'package:game/games/game.dart';
import 'package:game/respect/index.dart';

enum PlayerStatus {
  idle,
  running,
  attack,
  die,
}

class Player extends MovableHitboxComponent with HasGameRef<MyGame>, HasHitbox {
  Player(this.tileObject)
      : super(
          CircleHitbox.relative(
            tileObject.circle ?? 0.18, // 先写死0.18 后面再看看要不要改
            parentSize: tileObject.srcSize * RespectMap.scaleFactor,
            anchor: Anchor.center,
            position: Vector2.zero(),
          ),
        );

  /// 手柄控制
  late final JoystickComponent joystick;

  /// 玩家的动作状态组件
  late SpriteAnimationGroupComponent<PlayerStatus> statusComp;

  /// 移动速度
  double maxSpeed = 150.0;

  /// 是否是朝向左边，需要水平翻转
  bool isLeft = false;

  final RTileObject tileObject;

  @override
  Future<void>? onLoad() async {
    joystick = gameRef.joystick;
    statusComp = SpriteAnimationGroupComponent(
      animations: await R.createAnimations(PlayerStatus.values, 'player'),
      current: PlayerStatus.idle,
      // position: Vector2(RespectMap.characterBase.x / 2, 0),
      size: tileObject.spriteSize,
      anchor: tileObject.anchor ?? Anchor.center // const Anchor(0.5, 0.8),
    );
    await add(statusComp);
    await super.onLoad();
    if (DevTool.showPlayerDebug.isDebug) {
      statusComp.debugMode = true;
    }
    priority = 10000;
  }

  bool get isAttacking => statusComp.current == PlayerStatus.attack;

  @override
  void update(double dt) {
    // 手柄移动了
    if (!joystick.delta.isZero()) {
      if (!isAttacking) {
        changeStatus(PlayerStatus.running);
        move(joystick.relativeDelta * maxSpeed * dt);
      }
    } else {
      // 没有移动
      if (!isAttacking) {
        changeStatus(PlayerStatus.idle);
      }
    }
  }

  void move(Vector2 delta) {
    position.add(delta);
    _checkFlip(delta);
  }

  // 如果是左边则翻转
  void _checkFlip(Vector2 delta) {
    // 朝左边翻转人物
    final _isLeft = delta.x.isNegative;
    if (_isLeft != isLeft) {
      isLeft = _isLeft;
      if (_isLeft) {
        statusComp.scale = Vector2(-1, 1);
      } else {
        statusComp.scale = Vector2(1, 1);
      }
    }
  }

  /// 改变状态
  void changeStatus(PlayerStatus status) {
    statusComp.current = status;
  }

  /// 攻击
  void attack() {
    statusComp.current = PlayerStatus.attack;
    statusComp.animation!.onComplete = onAttackCompleted;
  }

  /// 攻击完成的回调函数
  void onAttackCompleted() {
    statusComp.animation!.reset();
    statusComp.current = PlayerStatus.idle;
    statusComp.animation!.onComplete = null;
  }
}

// extension JudgeExt on JoystickDirection {
//   Vector2 get sign {
//     switch (this) {
//       case JoystickDirection.idle:
//         return Vector2.zero();
//       case JoystickDirection.upLeft:
//         return Vector2(-1, -1);
//       case JoystickDirection.left:
//         return Vector2(-1, 0);
//       case JoystickDirection.downLeft:
//         return Vector2(-1, 1);
//       case JoystickDirection.up:
//         return Vector2(0, -1);
//       case JoystickDirection.down:
//         return Vector2(0, 1);
//       case JoystickDirection.upRight:
//         return Vector2(1, -1);
//       case JoystickDirection.right:
//         return Vector2(1, 0);
//       case JoystickDirection.downRight:
//         return Vector2(1, 1);
//     }
//   }
// }
