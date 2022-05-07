import 'package:game/common.dart';

class Coord {
  final int x;
  final int y;
  const Coord(this.x, this.y);

  @override
  String toString() {
    return 'rowColumn'.lang.args({
      'row': y,
      'column': x,
    });
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        ((other is Coord) && other.x == x && other.y == y);
  }

  @override
  int get hashCode => Object.hash(this, x, y);
}