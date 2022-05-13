import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/rendering.dart';
import 'package:flame/sprite.dart';
import 'package:game/common.dart';

final Future<SpriteSheet> joystickSheet = R.images.joystick.then((img) {
  return SpriteSheet.fromColumnsAndRows(
    image: img,
    columns: 6,
    rows: 1,
  );
});

Future<JoystickComponent> createJoystick() async {
  late final JoystickComponent joystick;
  final sheet = await joystickSheet;
  joystick = JoystickComponent(
    // 旋钮
    knob: SpriteComponent(
      sprite: sheet.getSpriteById(1),
      size: Vector2.all(100),
    )..setOpacity(0.5),
    background: SpriteComponent(
      sprite: sheet.getSpriteById(0),
      size: Vector2.all(120),
    )..setOpacity(0.5),
    margin: const EdgeInsets.only(left: 40, bottom: 40),
  );
  return joystick;
}

Future<HudButtonComponent> createButton(void Function() onButtonPress) async {
  final sheet = await joystickSheet;
  const double size = 80;
  return HudButtonComponent(
    button: SpriteComponent(
      sprite: sheet.getSpriteById(2),
      size: Vector2.all(size),
    ),
    buttonDown: SpriteComponent(
      sprite: sheet.getSpriteById(4),
      size: Vector2.all(size),
    ),
    margin: const EdgeInsets.only(right: 40, bottom: 60),
    onPressed: onButtonPress,
  );
}
