import 'package:flame/components.dart';
import 'package:game/common/utils/dev_tool.dart';

/// 敌人基类
mixin Enemy on PositionComponent {
  /// 感应敌人的距离
  double sensingDistance = 500;

  /// 可以攻击到[target]的距离
  double attackDistance = 30;

  /// 移动速度
  double speed = 10;

  /// 目标
  PositionComponent? target;

  bool _isFlipHorizontal = false;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    if (DevTool.showEnemyDebug.isDebug) {
      debugMode = true;
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
        attack();
      }
      return null;
    } else {
      return null;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
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

  /// 水平翻转
  void flipHorizontal();

  void move();

  void idle();

  void attack();
}
