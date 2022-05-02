import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/palette.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:game/common.dart';
import 'package:game/components/my_map.dart';
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
  double maxSpeed = 200.0;

  bool isLeft = false;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    final _size = Vector2(48, 48) * MyMap.scaleFactor; // MyMap.base,
    statusComp = SpriteAnimationGroupComponent(
      animations: await R.createAnimations(PlayerStatus.values, R.animations.player),
      current: PlayerStatus.idle,
      size: _size,
      position: Vector2.zero(),
      anchor: Anchor.center,
    );
    add(statusComp);
    size = _size;

    final hitBoxPaint = BasicPalette.white.paint()
      ..style = PaintingStyle.stroke;
    add(
      PolygonHitbox.relative(
        [
          Vector2(-1, 1),
          Vector2(1, 1),
          Vector2(1, -1),
          Vector2(-1, -1),
        ],
        parentSize: size,
      )
        ..paint = hitBoxPaint
        ..renderShape = true,
    );
  }

  final painter = Paint()..color= Colors.black12;

  @override
  void update(double dt) {
    // 手柄移动了
    if (!joystick.delta.isZero()) {
      changeStatus(PlayerStatus.running);
      position.add(joystick.relativeDelta * maxSpeed * dt);
      // 朝左边翻转人物
      final _isLeft = joystick.direction.isLeft;
      if (_isLeft != isLeft) {
        isLeft = _isLeft;
        if (_isLeft) {
          statusComp.scale = Vector2(-1, 1);
        } else {
          statusComp.scale = Vector2(1, 1);
        }
      }
    } else if (activeCollisions.isEmpty) {
      changeStatus(PlayerStatus.idle);
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    print('hit');
  }

  void changeStatus(PlayerStatus status) {
    statusComp.current = status;
  }
}

extension JudgeExt on JoystickDirection {
  bool get isLeft {
    switch(this) {
      case JoystickDirection.left:
      case JoystickDirection.downLeft:
      case JoystickDirection.upLeft:
        return true;
        default: return false;
    }
  }
}