import 'package:flame/components.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/input.dart';
import 'package:game/common.dart';
import 'package:game/components/joystick.dart';
import 'package:game/components/my_map.dart';
import 'package:flame/game.dart';
import 'package:game/components/player.dart';

class MyGame extends FlameGame
    with HasDraggables, HasCollisionDetection, TapDetector {
  MyGame({
    this.mapData,
  });

  final RMap? mapData;

  /// 地图
  late final MyMap myMap;

  /// 玩家
  late final Player player;

  /// 相机位置
  Vector2 cameraPosition = Vector2.zero();

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    // 轮盘
    final joystick = await createJoystick();

    // 玩家
    player = Player(joystick: joystick);

    // 地图
    myMap = MyMap(
      player: player,
      mapData: mapData,
    );
    await add(myMap);

    // print(myMap.size.toRect());
    camera.followComponent(
      player,
      worldBounds: myMap.size.toRect(),
    );
    add(joystick);

  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void onTap() {
    print(overlays.value);
    if (overlays.value.contains('backBtn')) {
      print(true);
      overlays.add('backBtn');
    }
  }
}
