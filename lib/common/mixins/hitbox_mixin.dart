import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:game/common/utils/dev_tool.dart';

mixin HasHitbox on PositionComponent {
  ShapeHitbox get hitbox;
  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    if (DevTool.showHitbox.isDebug) {
      // hitbox
      //   ..paint = DevTool.hitBoxPaint
      //   ..renderShape = true;
      hitbox.debugMode = true;
    }
    add(hitbox);
  }

  /// 获取 [hitbox] 的绝对坐标
  // Rect getHitboxRect() {
  //   final _a = position - (size.clone()..multiply(anchor.toVector2()));
  //   final _b = hitbox.position -
  //       (hitbox.size.clone()..multiply(hitbox.anchor.toVector2()));
  //   return Rect.fromLTWH(
  //     _a.x + _b.x,
  //     _a.y + _b.y,
  //     hitbox.size.x,
  //     hitbox.size.y,
  //   );
  // }
}
