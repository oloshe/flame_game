import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:game/common.dart';
import 'package:game/common/mixins/custom_collision.dart';
import 'package:game/common/utils/dev_tool.dart';
import 'package:game/components/respect_map.dart';
import 'package:game/games/game.dart';

enum PlayerStatus {
  idle,
  running,
  attack,
  die,
}

class Player extends PositionComponent
    with HasGameRef<MyGame>, HasHitbox, CollisionCallbacks {
  Player({
    required this.joystick,
  }) : super(
          size: RespectMap.base,
          anchor: Anchor.center,
        );

  /// 手柄控制
  final JoystickComponent joystick;

  /// 玩家的动作状态组件
  late SpriteAnimationGroupComponent<PlayerStatus> statusComp;

  /// 移动速度
  double maxSpeed = 150.0;

  /// 是否是朝向左边，需要水平翻转
  bool isLeft = false;

  late Vector2 hitboxinitialPosition = Vector2(0, size.y);

  /// 碰撞体
  @override
  // late final PolygonHitbox hitbox = PolygonHitbox.relative(
  //   cover,
  //   position: hitboxinitialPosition.clone(),
  //   anchor: Anchor.center,
  //   parentSize: size,
  // );
  late final RectangleHitbox hitbox = RectangleHitbox(size: size);

  static final cover = [
    Vector2(0.6, 0),
    Vector2(0.6, 0.4),
    Vector2(-0.6, 0.4),
    Vector2(-0.6, 0),
  ];

  @override
  Future<void>? onLoad() async {
    statusComp = SpriteAnimationGroupComponent(
      animations:
          await R.createAnimations(PlayerStatus.values, R.animations.player),
      current: PlayerStatus.idle,
      position: Vector2.zero(),
      size: RespectMap.characterBase,
      anchor: Anchor.center,
    );
    await add(statusComp);
    await super.onLoad();
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

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    // if (intersectionPoints.length == 2) {
    //   final p1 = intersectionPoints.first;
    //   final p2 = intersectionPoints.last;
    //   final rect = getHitboxRect();
    //   if (p1.x == p2.x) {
    //     if (p1.x < rect.left + rect.width / 2) {
    //       _realMove(Vector2(p1.x - rect.left, 0)); // 向右矫正
    //     } else {
    //       _realMove(Vector2(p1.x - rect.right, 0)); // 向左矫正
    //     }
    //   } else if (p1.y == p2.y) {
    //     if (p1.y < rect.top + rect.height / 2) {
    //       _realMove(Vector2(0, p1.y - rect.top)); // 向上矫正
    //     } else {
    //       _realMove(Vector2(0, p1.y - rect.bottom)); // 向下矫正
    //     }
    //   } else {
    //     final center = rect.center;
    //     Vector2 hitboxCenter = Vector2(center.dx, center.dy);
    //     final d1 = hitboxCenter.distanceTo(p1);
    //     final d2 = hitboxCenter.distanceTo(p2);
    //     if (d1 < d2) {
    //       _tmp(p1, hitboxCenter, rect);
    //     } else {
    //       _tmp(p2, hitboxCenter, rect);
    //     }
    //   }
    // }
    // final list = intersectionPoints.toList(growable: false);
    // final lx = list..sort(compare(Axis.horizontal));
    // final ly = list..sort(compare(Axis.vertical));
    // Vector2 delta = Vector2.zero();
    // final rect = getHitboxRect();
    // final sign = joystick.direction.sign;
    // if (sign.x < 0) {
    //   delta.x = lx.first.x - rect.left + 1;
    // } else if (sign.x > 0) {
    //   delta.x = rect.right - lx.last.x - 1;
    // }
    // if (sign.y < 0) {
    //   delta.y = ly.first.y - rect.top + 1;
    // } else if (sign.y > 0) {
    //   delta.y = rect.bottom - ly.last.y - 1;
    // }
    // print('-----');
    // print(sign);
    // print('lx = $lx');
    // print('ly = $ly');
    // _realMove(delta);
  }

  int Function(Vector2 a, Vector2 b) compare(Axis axis) {
    return (a, b) {
      if (axis == Axis.horizontal) {
        return a.x.compareTo(b.x);
      } else {
        return a.y.compareTo(b.y);
      }
    };
  }

  void _tmp(Vector2 p, Vector2 center, Rect rect) {
    final dx = (p.x - center.x).abs();
    final dy = (p.y - center.y).abs();
    if (dx < dy) {
      if (p.x < center.x) {
        _realMove(Vector2(p.x - rect.left, 0)); // 向右矫正
      } else {
        _realMove(Vector2(p.x - rect.right, 0)); // 向左矫正
      }
    } else {
      if (p.y < center.y) {
        _realMove(Vector2(0, p.y - rect.top)); // 向上矫正
      } else {
        _realMove(Vector2(0, p.y - rect.bottom)); // 向下矫正
      }
    }
  }
}

extension JudgeExt on JoystickDirection {
  Vector2 get sign {
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
