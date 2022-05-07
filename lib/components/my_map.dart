import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:game/common.dart';
import 'package:game/components/collision_sprite.dart';
import 'package:game/components/player.dart';
import 'package:image/image.dart';

class MyMap extends PositionComponent with HasGameRef {
  /// 源地图的基本尺寸
  static final srcBase = Vector2(16, 16);

  /// 显示上缩放的倍数
  static const scaleFactor = 30 / 16; // 1.875

  /// 缩放之后的实际显示向量
  static final base = srcBase * scaleFactor;

  MyMap({
    required this.player,
    this.mapData,
  });

  final RMap? mapData;

  Player player;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    RMap realMap = mapData ?? await R.mapMgr.loadMap('home');
    size = realMap.size..multiply(base);
    await draw(realMap);
    if (size.x < gameRef.size.x) {
      position.x = (gameRef.size.x - size.x) / 2;
    }
    if (size.y < gameRef.size.y) {
      position.y = (gameRef.size.y - size.y) / 2;
    }
    player.position = size / 2;
    player.priority = 100;
    await add(player);
    add(RectangleHitbox());
  }

  Future<void> draw(RMap mapData) async {
    await mapData.forEachLayer((layer) async {
      Map<String, SpriteBatch> batch = {};
      for (var y = 0; y < mapData.height; y++) {
        for (var x = 0; x < mapData.width; x++) {
          if (layer.matrix[y][x] != RMapGlobal.emptyTile) {
            await drawTile(
              id: layer.matrix[y][x],
              pos: Vector2(x.toDouble(), y.toDouble()),
              layer: layer,
              onBatch: (pic, sp, size, pos, index) {
                if (!batch.containsKey(pic)) {
                  batch[pic] = SpriteBatch(sp.image);
                }
                batch[pic]!.add(
                  source: Rect.fromLTWH(
                    sp.srcPosition.x,
                    sp.srcPosition.y,
                    sp.srcSize.x,
                    sp.srcSize.y,
                  ),
                  scale: MyMap.scaleFactor,
                  offset: pos,
                );
              },
            );
          }
        }
      }
      for (final item in batch.entries) {
        await add(SpriteBatchComponent(
          spriteBatch: item.value,
        ));
      }
    });
  }

  Future<void> drawTile({
    required int id,
    required Vector2 pos,
    required RMapLayerData layer,
    required void Function(
            String pic, Sprite, Vector2 size, Vector2 pos, int priority)
        onBatch,
  }) async {
    RTileData tileData = R.getTileById(id)!;
    Vector2 spriteSize = tileData.size.clone()..multiply(base);
    Vector2 spritePosition = pos..multiply(base);
    final sprite = await tileData.getSprite();
    // 如果有碰撞
    if (tileData.hit) {
      if (tileData.cover != null) {
        await add(CoverCollisionSprite(
          sprite,
          cover: tileData.cover!,
          size: spriteSize,
          position: spritePosition,
          priority: layer.index,
          relation: tileData.polygon,
        ));
      } else {
        // 单独生成带有碰撞的
        await add(HitboxSprite(
          sprite,
          size: spriteSize,
          position: spritePosition,
          priority: layer.index,
          relation: tileData.polygon,
        ));
      }
    } else {
      /// 如果是纯图片sprite，则添加到batch里面，到最后一次性
      onBatch(tileData.pic, sprite, spriteSize, spritePosition, layer.index);
      // await add(SpriteComponent(
      //   sprite: sprite,
      //   size: spriteSize,
      //   position: spritePosition,
      //   priority: layer.index,
      // ));
    }
  }
}
