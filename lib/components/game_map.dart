import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

class GameMap extends PositionComponent {
  final Map<String, int>? objectBuilders;

  GameMap({
    this.objectBuilders,
  });

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    final tiledMapComp = await TiledComponent.load('home.tmx', Vector2.all(16));
    add(tiledMapComp);
    size = tiledMapComp.size;
    print(size);
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
