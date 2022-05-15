import 'package:flame/image_composition.dart';
import 'package:game/common/base/moveable_hitbox.dart';
import 'package:game/common/utils/dev_tool.dart';
import 'package:game/components/joystick/joystick.dart';
import 'package:game/components/respect_map.dart';
import 'package:flame/game.dart';
import 'package:game/components/characters/player.dart';
import 'dart:math' as math;

import 'package:game/respect/index.dart';

class MyGame extends FlameGame
    with
        HasDraggables,
        HasCollisionDetection,
        HasTappables,
        AllMovable,
        FPSCounter {
  MyGame({
    this.mapData,
  }) : super();

  final RMap? mapData;

  /// 地图
  late final RespectMap myMap;

  /// 玩家
  late final Player player;

  /// 相机位置
  Vector2 cameraPosition = Vector2.zero();

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    // 轮盘
    final joystick = await createJoystick();
    final button = await createButton(onButtonPress);

    // 玩家
    player = Player(joystick: joystick);

    // 地图
    myMap = RespectMap(
      player: player,
      mapData: mapData,
    );
    await add(myMap);

    // await add(player);

    // add(Skeleton()..position = size / 2);

    final rect1 = size.toRect();
    final rect2 = myMap.size.toRect();
    camera.followComponent(
      player,
      worldBounds: Rect.fromLTWH(
        0,
        0,
        math.max(rect1.width, rect2.width),
        math.max(rect1.height, rect2.height),
      ),
    );
    add(joystick);
    add(button);
  }

  void onButtonPress() {
    player.attack();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final fpsCount = fps(120);
    DevTool.fpsTextConfig.render(
      canvas,
      fpsCount.toStringAsFixed(1),
      Vector2(10, 20),
    );
  }
}
