part of '../common.dart';

class _Utils {

  Vector2? vec2Field(List<dynamic>? list) {
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

  Vector2 vec2FieldDefault(List<dynamic>? list) {
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

  List<Vector2>? polygonField(List<dynamic>? list) {
    return list == null || list.length < 3
        ? null
        : list
        .map((e) => vec2FieldDefault(e as List<dynamic>))
        .toList(growable: false);
  }

  material.Locale str2Locale(String str) {
    final arr = str.split('_');
    return material.Locale(arr[0], arr[1]);
  }
}

final _Utils utils = _Utils();