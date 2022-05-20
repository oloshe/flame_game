import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:game/common/base/sprite_batch_map.dart';
import 'package:game/components/collision_sprite.dart';
import 'package:game/components/characters/player.dart';
import 'package:game/respect/index.dart';

class RespectMap extends PositionComponent with HasGameRef {
  /// 源地图的基本尺寸
  static final srcBase = Vector2(16, 16);

  /// 人物的基本尺寸
  static final characterSrcSize = Vector2(48, 48);

  /// 显示上缩放的倍数
  static const scaleFactor = 30 / 16; // 1.875

  /// 缩放之后的实际显示向量
  static final base = srcBase * scaleFactor;

  /// 缩放之后的实际显示向量
  static final characterBase = characterSrcSize * scaleFactor;

  RespectMap({
    required this.player,
    this.mapData,
  });

  final RMap? mapData;

  Player player;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    RMap realMap = mapData ?? await R.mapMgr.loadMap('tree');
    size = realMap.size..multiply(base);
    await draw(realMap);
    if (size.x < gameRef.size.x) {
      position.x = (gameRef.size.x - size.x) / 2;
    }
    if (size.y < gameRef.size.y) {
      position.y = (gameRef.size.y - size.y) / 2;
    }
    player.position = size / 2
      ..add(Vector2(0, 20));
    await add(player);
    add(RectangleHitbox());
  }

  Future<void> draw(RMap mapData) async {
    await mapData.forEachLayer((layer) async {
      SpriteBatchMap batch = SpriteBatchMap();
      for (var y = 0; y < mapData.height; y++) {
        for (var x = 0; x < mapData.width; x++) {
          if (layer.matrix[y][x] != RMapGlobal.emptyTile) {
            await drawTile(
              id: layer.matrix[y][x],
              pos: Vector2(x.toDouble(), y.toDouble()),
              batch: batch,
            );
          }
        }
      }
      await addAll(batch.intoIter());
    });
  }

  Future<void> drawTile({
    required int id,
    required Vector2 pos,
    required SpriteBatchMap batch,
  }) async {
    RTileBase tileData = R.getTileById(id)!;
    Vector2 spriteSize = tileData.spriteSize;
    Vector2 spritePosition = pos..multiply(base);
    if (tileData is RTileHit) {
      if (tileData is RTileObject) {
        final object = await tileData.buildObject(spritePosition);
        if (object != null) {
          await add(object);
        }
        return;
      }
      await add(ShapeSprite.factory(
        sprite: tileData.getSprite(),
        size: spriteSize,
        position: spritePosition,
        tileData: tileData,
      ));
      return;
    }
    batch.addTile(tileData, pos);
  }
}
