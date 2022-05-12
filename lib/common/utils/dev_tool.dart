import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DevTool {
  static final fpsTextConfig = TextPaint(
    style: const TextStyle(
      color: Colors.white,
    ),
  );

  static const _showHitbox = true;

  static void showHitbox(ShapeHitbox hitbox) {
    if (!_showHitbox) {
      return;
    } else {
      hitbox
        ..paint = hitBoxPaint
        ..renderShape = true;
    }
  }

  static final Paint hitBoxPaint = Paint()
    ..color = const Color(0x55ffffff)
    ..style = PaintingStyle.fill;

  static const showCoverBaseline = true;

  static const debugMode = true;
}
