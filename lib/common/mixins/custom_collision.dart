import 'package:flame/components.dart';
import 'package:game/common/geometry/shape.dart';
import 'package:game/game.dart';

mixin HasCustomCollision on MyGame {
  final List<HasMyShape> _allShape = [];
  List<HasMyShape> get allShape => _allShape;

  void checkCustomCollision() {

  }
}

mixin HasMyShape on PositionComponent {
  late MyShape shape;

  @override
  void onMount() {
    final game = findParent<MyGame>();

    if (game is HasCustomCollision) {
      game.allShape.add(this);
    }

    super.onMount();
  }
}