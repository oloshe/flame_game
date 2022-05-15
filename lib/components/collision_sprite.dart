import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:game/common/base/moveable_hitbox.dart';
import 'package:game/common/mixins/custom_collision.dart';
import 'package:game/common/utils/dev_tool.dart';
import 'package:game/games/game.dart';
import 'package:game/common/base/dynamic_priority.dart';

import 'package:game/common.dart';

class ShapeSprite extends SpriteComponent with HasHitbox, DynamicPriorityComponent {
  ShapeSprite(
    Sprite sprite, {
    required Vector2 size,
    required Vector2 position,
    this.relation,
    Anchor? anchor,
  }) : super(
          sprite: sprite,
          size: size,
          position: anchor == null
              ? position
              : position + (size.clone()..multiply(anchor.toVector2())),
          anchor: anchor,
        ) {
    if (relation != null) {
      hitbox = PolygonHitbox.relative(relation!, parentSize: size);
    } else {
      hitbox = RectangleHitbox(size: size);
    }
    if (DevTool.showShapeSpriteDebug.isDebug) {
      debugMode = true;
    }
  }
  List<Vector2>? relation;

  factory ShapeSprite.factory({
    required Sprite sprite,
    required RTileData tileData,
    required Vector2 size,
    required Vector2 position,
  }) {
    return ShapeSprite(
      sprite,
      size: size,
      position: position,
      relation: tileData.polygon,
      anchor: tileData.anchor,
    );
  }

  @override
  late ShapeHitbox hitbox;
}
