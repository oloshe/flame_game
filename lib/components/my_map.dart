import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:game/common.dart';
import 'package:game/components/collision_sprite.dart';

class MyMap extends PositionComponent {
  /// 源地图的基本尺寸
  static final srcBase = Vector2(16, 16);

  /// 显示上缩放的倍数
  static const scaleFactor = 30 / 16; // 1.875

  /// 缩放之后的实际显示向量
  static final base = srcBase * scaleFactor;

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
    final sprite = await tileData.getSprite();
    if (id == 201) {
      final ret = CollisionSprite(
        sprite,
        size: spriteSize,
        position: spritePosition,
        priority: layer.index,
      );
      await add(ret);
      print(ret.size);
      return;
    }
    await add(SpriteComponent(
      sprite: sprite,
      size: spriteSize,
      position: spritePosition,
      priority: layer.index,
    ));
  }
}
