import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:game/common.dart';
import 'package:game/common/utils/dev_tool.dart';

mixin HasHitbox on PositionComponent {
  ShapeHitbox get hitbox;
  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    DevTool.showHitbox(hitbox);
    add(hitbox);
  }

  /// 获取 [hitbox] 的绝对坐标
  Rect getHitboxRect() {
    final _a = position - (size.clone()..multiply(anchor.toVector2()));
    final _b = hitbox.position -
        (hitbox.size.clone()..multiply(hitbox.anchor.toVector2()));
    return Rect.fromLTWH(
      _a.x + _b.x,
      _a.y + _b.y,
      hitbox.size.x,
      hitbox.size.y,
    );
  }
}

mixin CoverMixin on SpriteComponent implements HasPaint {
  static double coverOpacity = 0.8;

  double get cover;
  double get target;

  late double coverY;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    coverY = position.y + size.y * cover;
  }

  @override
  void update(double dt) {
    super.update(dt);
    checkCover();
  }

  bool _isCover = false;
  int? _oldPriority;

  void checkCover() {
    final needCover = coverY > target;
    if (_isCover != needCover) {
      _isCover = needCover;
      if (needCover) {
        _oldPriority = priority;
        setOpacity(coverOpacity);
        priority = 200;
      } else {
        setOpacity(1);
        priority = _oldPriority!;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (DevTool.showCoverBaseline) {
      final y = cover * size.y;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.x, y),
        utils.painter,
      );
    }
  }
}
