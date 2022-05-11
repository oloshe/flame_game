import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:tiled/tiled.dart';

class GameMap extends PositionComponent {
  final Map<String, ObjectBuilder>? objectBuilders;
  final String? objectLayer;

  GameMap({
    this.objectBuilders,
    this.objectLayer = "GameObjects"
  });

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    final tiledMapComp = await TiledComponent.load('home.tmx', Vector2.all(16));
    add(tiledMapComp);
    if (!tiledMapComp.tileMap.map.infinite) {
      size = tiledMapComp.size;
    }

    if (objectLayer != null) {
      final groups = tiledMapComp.tileMap.getLayer<ObjectGroup>(objectLayer!);
      // 遍历 builder
      if (groups != null && objectBuilders != null) {
        for(final obj in groups.objects) {
          if (objectBuilders!.containsKey(obj.name)) {
            final comp = await objectBuilders![obj.name]!.call(obj);
            if (comp != null) {
              add(comp);
            }
          }
        }
      }
    }
  }
}

extension TiledMapExt on TiledComponent {
  Vector2 get size {
    return Vector2(
      tileMap.map.width.toDouble(),
      tileMap.map.height.toDouble(),
    )..multiply(Vector2(
      tileMap.map.tileWidth.toDouble(),
      tileMap.map.tileHeight.toDouble(),
    ));
  }
}

typedef ObjectBuilder = FutureOr<PositionComponent?> Function(TiledObject obj);