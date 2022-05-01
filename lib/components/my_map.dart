import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:game/common.dart';

class MyMap extends PositionComponent {
  static final srcBase = Vector2(16, 16);
  static final base = Vector2(30, 30);

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    RMap mapData = await R.mapMgr.loadMap('home');
    size = mapData.size..multiply(base);
    await draw(mapData);
  }

  Future<void> draw(RMap mapData) async {
    await mapData.forEachLayer((layer) async {
      for (var y = 0; y < mapData.height; y++) {
        for (var x = 0; x < mapData.width; x++) {
          final id = layer.matrix[y][x];
          if (id != RMapGlobal.emptyTile) {
            await drawTile(
              layer.matrix[y][x],
              Vector2(x.toDouble(), y.toDouble()),
              layer,
            );
          }
        }
      }
    });
  }

  Future<void> drawTile(int id, Vector2 pos, RMapLayerData layer) async {
    RTileData tileData = R.getTileById(id)!;
    Vector2 spriteSize = tileData.size.clone()..multiply(base);
    Vector2 spritePosition = pos..multiply(base);
    await add(SpriteComponent(
      sprite: await tileData.getSprite(),
      size: spriteSize,
      position: spritePosition,
      priority: layer.index,
    ));
  }
}
