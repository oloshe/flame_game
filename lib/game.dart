import 'package:flame/image_composition.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:game/common.dart';
import 'package:game/common/geometry/shape.dart';
import 'package:game/common/mixins/custom_collision.dart';
import 'package:game/components/enemies/skeleton.dart';
import 'package:game/components/joystick.dart';
import 'package:game/components/my_map.dart';
import 'package:flame/game.dart';
import 'package:game/components/player.dart';
import 'dart:math' as math;

class MyGame extends Forge2DGame
    with
        HasDraggables,
        HasCollisionDetection,
        HasTappables,
        FPSCounter {
  MyGame({
    this.mapData,
  }) : super(
          gravity: Vector2(0, 0),
          zoom: 1,
        );

  static const showHitbox = true;

  static final fpsTextConfig = TextPaint(
      style: const TextStyle(
    color: Colors.white,
  ));

  final RMap? mapData;

  /// 地图
  late final MyMap myMap;

  /// 玩家
  late final Player player;

  /// 相机位置
  Vector2 cameraPosition = Vector2.zero();

  late final SingletonCollision collisionManager;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    // 轮盘
    final joystick = await createJoystick();
    final button = await createButton(onButtonPress);

    collisionManager = SingletonCollision();
    ShapeMgr.init();

    // 玩家
    player = Player(joystick: joystick);

    // 地图
    myMap = MyMap(
      player: player,
      mapData: mapData,
    );
    await add(myMap);

    await add(collisionManager);

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
    fpsTextConfig.render(
      canvas,
      fpsCount.toStringAsFixed(1),
      Vector2(10, 20),
    );
  }
}
