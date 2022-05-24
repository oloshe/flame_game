import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:game/common/base/moveable_hitbox.dart';
import 'package:game/common/utils/dev_tool.dart';
import 'package:game/components/attack_component.dart';
import 'package:game/respect/index.dart';

/// 敌人基类
abstract class Enemy extends MovableHitboxComponent {
  /// 感应敌人的距离
  double sensingDistance = 500;

  /// 可以攻击到[target]的距离
  double attackDistance = 30;

  /// 移动速度
  double speed = 10;

  /// 攻击的冷却CD
  double attackCD = 1;
  bool _attackInCD = false;
  double _attackClock = 0;

  /// 目标
  PositionComponent? target;

  int life = 3;

  bool _isFlipHorizontal = false;

  Enemy(RTileObject tileObject, ShapeHitbox hitbox) : super(tileObject, hitbox);

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    if (DevTool.showEnemyDebug.isDebug) {
      // debugMode = true;
    }
  }

  Vector2? checkEnmity() {
    if (target == null) {
      return null;
    }
    final playerPos = target!.position;
    final distance = playerPos.distanceTo(position);
    // 是否在感应范围内
    if (distance < sensingDistance) {
      // 是否距离大于攻击距离
      if (distance > attackDistance) {
        return (playerPos - position).normalized();
      } else {
        if (!_attackInCD) {
          attack();
        }
      }
      return null;
    } else {
      return null;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_attackInCD) {
      _attackClock += dt;
      if (_attackClock >= attackCD) {
        _attackInCD = false;
        _attackClock = 0;
      }
    }
    if (!canMove()) {
      return;
    }
    final delta = checkEnmity();
    if (delta != null) {
      if (delta.x < 0) {
        if (!_isFlipHorizontal) {
          _isFlipHorizontal = true;
          flipHorizontal();
        }
      } else if (delta.x > 0) {
        if (_isFlipHorizontal) {
          _isFlipHorizontal = false;
          flipHorizontally();
        }
      }
      position.add(delta * dt * speed);
      move();
    } else {
      idle();
    }
  }

  bool canMove();

  /// 水平翻转
  void flipHorizontal();

  void move();

  void idle();

  @mustCallSuper
  void attack() {
    _attackInCD = true;
  }

  /// 受伤
  @mustCallSuper
  void hurt() {
    life -= 1;
    if (life <= 0) {
      die();
    }
  }

  void die();

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is AttackComponent) {
      hurt();
    }
  }
}
