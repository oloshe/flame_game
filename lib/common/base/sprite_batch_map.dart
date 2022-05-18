import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/sprite.dart';
import 'package:game/respect/index.dart';

class SpriteBatchMap {
  final Map<String, SpriteBatch> _inner = {};

  void addTile(RTileBase tileData, Vector2 position) async {
    tileData.batchConfiguration(_inner, position);
  }

  Iterable<SpriteBatchComponent> intoIter() {
    return _inner.entries.map((e) => SpriteBatchComponent(
      spriteBatch: e.value
    ));
  }

  void render(Canvas canvas) {
    intoIter().forEach((comp) {
      comp.render(canvas);
    });
  }
}