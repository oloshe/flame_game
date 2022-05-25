import 'dart:ui';

import 'package:flame/components.dart';

class CallbackAnimationGroup<T> extends SpriteAnimationGroupComponent<T> {
  final Map<T, void Function()> onFinish;
  CallbackAnimationGroup(
    this.onFinish,
    Map<T, SpriteAnimation>? animations,
    Map<T, bool>? removeOnFinish,
    Paint? paint,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    Iterable<Component>? children,
    int? priority,
  ) : super(
          removeOnFinish: removeOnFinish,
          position: position,
          size: size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          children: children,
          priority: priority,
        ) {
    if (paint != null) {
      this.paint = paint;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (onFinish[current] != null && (animation?.done() ?? false)) {
      onFinish[current]!.call();
    }
  }
}
