part of '../common.dart';

class _Utils {

  Vector2? vec2fromJson(List<dynamic>? list) {
    if (list == null) {
      return null;
    }
    return Vector2.array((list).map((e) {
      if (e is int) {
        return e.toDouble();
      } else {
        return e as double;
      }
    }).toList(growable: false));
  }

  Vector2 vec2fromJsonDefault(List<dynamic>? list) {
    if (list == null) {
      return Vector2.zero();
    }
    return Vector2.array((list).map((e) {
      if (e is int) {
        return e.toDouble();
      } else {
        return e as double;
      }
    }).toList(growable: false));
  }
}

final _Utils utils = _Utils();