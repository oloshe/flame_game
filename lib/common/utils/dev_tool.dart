import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DevTool {

  static const debugMode = true;
  static const showCoverBaseline = true;
  static const showHitbox = false;
  static const showPlayerDebug = false;

  static bool whenDebug(bool value) {
    return debugMode && value;
  }

  static final Paint hitBoxPaint = Paint()
    ..color = const Color(0x55ffffff)
    ..style = PaintingStyle.fill;

  static final Paint coverPaint = Paint()
    ..color = const Color(0xffff0000)
    ..style = PaintingStyle.fill;

  static final fpsTextConfig = TextPaint(
    style: const TextStyle(
      color: Colors.white,
    ),
  );
}

extension DevExt on bool {
  bool get isDebug {
    return DevTool.whenDebug(this);
  }
}
