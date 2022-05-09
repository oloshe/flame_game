import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/palette.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:game/common.dart';
import 'package:game/components/collision_sprite.dart';
import 'package:game/components/my_map.dart';
import 'package:game/components/tile_hitbox.dart';
import 'package:game/game.dart';

enum PlayerStatus {
  idle,
  running,
  attack,
  die,
}

class Player extends PositionComponent
    with HasGameRef<MyGame>, CollisionCallbacks {
  Player({
    required this.joystick,
  });

  /// 手柄控制
  final JoystickComponent joystick;

  /// 玩家的动作状态组件
  late SpriteAnimationGroupComponent<PlayerStatus> statusComp;

  /// 移动速度
  double maxSpeed = 150.0;

  /// 是否是朝向左边，需要水平翻转
  bool isLeft = false;

  /// 是否有碰撞
  bool _hasCollided = false;

  /// 轮盘方向
  JoystickDirection _collisionDirection = JoystickDirection.idle;

  /// 碰撞体
  late final PolygonHitbox hitBox;

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
    add(statusComp);
    size = MyMap.base;

    final hitBoxPaint = BasicPalette.white.paint()
      ..style = PaintingStyle.stroke;

    hitBox = PolygonHitbox.relative(
      [
        Vector2(0.6, 0),
        Vector2(0.6, 0.4),
        Vector2(-0.6, 0.4),
        Vector2(-0.6, 0),
      ],
      anchor: Anchor.center,
      position: Vector2(0, size.y),
      parentSize: size,
    );
    if (MyGame.showHitbox) {
      hitBox
        ..paint = hitBoxPaint
        ..renderShape = true;
    }

    add(hitBox);
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
    if (_hasCollided) {
      final sign = _collisionDirection.signVector;
      var newDelta = delta.clone();
      if (delta.x.sign == sign.x) {
        newDelta.x = 0;
      }
      if (delta.y.sign == sign.y) {
        newDelta.y = 0;
      }
      position.add(newDelta);
    } else {
      position.add(delta);
    }
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

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (!_hasCollided) {
      if (other is TileHitbox || other is MyMap) {
        _hasCollided = true;
        _collisionDirection = joystick.direction;
        print(intersectionPoints);
      }
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is TileHitbox || other is MyMap) {
      _hasCollided = false;
      _collisionDirection = JoystickDirection.idle;
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
