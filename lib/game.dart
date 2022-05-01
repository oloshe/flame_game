import 'package:flame/image_composition.dart';
import 'package:game/components/joystick.dart';
import 'package:game/components/my_map.dart';
import 'package:flame/game.dart';
import 'package:game/components/player.dart';

class MyGame extends FlameGame with HasDraggables, HasCollisionDetection {
  /// 地图
  late final MyMap myMap;

  /// 玩家
  late final Player player;
  Vector2 cameraPosition = Vector2.zero();
  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    // 地图
    myMap = MyMap();
    await add(myMap);

    // 轮盘
    final joystick = await createJoystick();

    // 玩家
    player = Player(joystick: joystick)
      ..width = 20
      ..height = 20;
    player.position = size / 2;

    camera.followComponent(
      player,
      worldBounds: myMap.size.toRect(),
    );
    await add(player);
    add(joystick);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }
}