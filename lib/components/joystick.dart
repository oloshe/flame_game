import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/rendering.dart';
import 'package:flame/sprite.dart';
import 'package:game/common.dart';

Future<JoystickComponent> createJoystick() async {
  late final JoystickComponent joystick;
  final image = await R.images.joystick;

  final sheet = SpriteSheet.fromColumnsAndRows(
    image: image,
    columns: 6,
    rows: 1,
  );
  joystick = JoystickComponent(
    // 旋钮
    knob: SpriteComponent(
      sprite: sheet.getSpriteById(1),
      size: Vector2.all(100),
    )..setOpacity(0.8),
    background: SpriteComponent(
      sprite: sheet.getSpriteById(0),
      size: Vector2.all(120),
    )..setOpacity(0.8),
    margin: const EdgeInsets.only(left: 40, bottom: 40),
  );
  return joystick;
}
