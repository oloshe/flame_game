import 'dart:math';

import 'package:flame/components.dart';

/// 动态调整层级 根据 position的y值
mixin DynamicPriorityComponent on PositionComponent {
  @override
  Future<void>? onLoad() async {
    position.addListener(onPositionChange);
    onPositionChange();
    await super.onLoad();
  }

  int _oldPriority = 0;

  void onPositionChange() {
    final y100 = (position.y * 100).toInt();
    final newPriority = max(100, y100);
    if (newPriority != _oldPriority) {
      _oldPriority = newPriority;
      priority = newPriority;
    }
  }
}
