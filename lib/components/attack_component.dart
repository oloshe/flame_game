import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:game/common.dart';
import 'package:game/common/utils/dev_tool.dart';

class AttackComponent extends PositionComponent with CollisionCallbacks {
  final Iterable<ShapeHitbox> hitboxes;
  AttackComponent({
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    required this.hitboxes,
    int? priority,
  }) : super(
          position: position,
          size: size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          priority: priority,
        );

  @override
  Future<void>? onLoad() {
    if (DevTool.showAttackDebug.isDebug) {
      for (var e in hitboxes) {
        e.debugMode = true;
      }
    }
    addAll(hitboxes);
    return super.onLoad();
  }
}


// class AttackComponent extends CompositeHitbox {
//   final Iterable<ShapeHitbox> attackHitboxs;
//   AttackComponent(this.attackHitboxs) : super(anchor: Anchor.center);

//   @override
//   Future<void>? onLoad() {
//     if (DevTool.showAttackDebug.isDebug) {
//       for (var e in attackHitboxs) {
//         e.debugMode = true;
//         logger.i(e.size);
//       }
//     }
//     addAll(attackHitboxs);
//     return super.onLoad();
//   }
// }
