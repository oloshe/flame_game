import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:game/common.dart';
import 'package:game/common/geometry/rectangle.dart';
import 'package:game/common/geometry/shape.dart';
import 'package:game/components/my_map.dart';
import 'package:game/games/game.dart';

enum PlayerStatus {
  idle,
  running,
  attack,
  die,
}

class Player extends PositionComponent with HasGameRef<MyGame> {
  Player({
    required this.joystick,
  }) : super(size: MyMap.base);

  /// 手柄控制
  final JoystickComponent joystick;

  /// 玩家的动作状态组件
  late SpriteAnimationGroupComponent<PlayerStatus> statusComp;

  /// 移动速度
  double maxSpeed = 150.0;

  /// 是否是朝向左边，需要水平翻转
  bool isLeft = false;

  /// 碰撞体
  late final MyRectangleShape shape;
  late final PolygonHitbox hitbox;

  static final cover = RTileCoverData(
    size: Vector2(0.6, 0.2),
    offset: Vector2(0, 0),
  );

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    statusComp = SpriteAnimationGroupComponent(
      animations:
          await R.createAnimations(PlayerStatus.values, R.animations.player),
      current: PlayerStatus.idle,
      position: Vector2.zero(),
      size: MyMap.characterBase,
      anchor: Anchor.center,
    );
    await add(statusComp);

    shape = MyRectangleShape.percentage(
      cover,
      size: size,
      position: position,
      anchor: Anchor.center,
    );

    ShapeMgr.createShape(shape);

    // hitbox = PolygonHitbox.relative(
    //   vertices,
    //   position: Vector2(0, size.y),
    //   anchor: Anchor.center,
    //   parentSize: size,
    // )
    //   ..paint = MyShape.paint
    //   ..renderShape = true;

    // add(hitbox);
  }

  final painter = Paint()..color = Colors.black12;

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
    // final sign = delta.normalized();
    // var newDelta = delta.clone();
    // if (delta.x.sign == sign.x) {
    //   newDelta.x = 0;
    // }
    // if (delta.y.sign == sign.y) {
    //   newDelta.y = 0;
    // }
    // final newPos = position + delta;
    // MyRectangleShape()
    _realMove(delta);
    _checkFlip(delta);
  }

  void _realMove(Vector2 delta) {
    position.add(delta);
    shape.position = position;
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

extension JudgeExt on JoystickDirection {
  Vector2 get signVector {
    switch (this) {
      case JoystickDirection.idle:
        return Vector2.zero();
      case JoystickDirection.upLeft:
        return Vector2(-1, -1);
      case JoystickDirection.left:
        return Vector2(-1, 0);
      case JoystickDirection.downLeft:
        return Vector2(-1, 1);
      case JoystickDirection.up:
        return Vector2(0, -1);
      case JoystickDirection.down:
        return Vector2(0, 1);
      case JoystickDirection.upRight:
        return Vector2(1, -1);
      case JoystickDirection.right:
        return Vector2(1, 0);
      case JoystickDirection.downRight:
        return Vector2(1, 1);
    }
  }
}
