part of '../../common.dart';

extension TranslationExt on String {
  String get lang {
    return Translations.instance.translate(this);
  }

  String get langWatch {
    return MyApp.navKey.currentContext!.watch<Translations>().translate(this);
  }

  String args(Map<String, Object> args) {
    var result = this;
    for (final entry in args.entries) {
      result = result.replaceAll('@${entry.key}', entry.value.toString());
    }
    return result;
  }
}

extension JsonExt on Map<String, dynamic> {
  List<dynamic>? getList(String key) => this[key];
}

extension SerdeListExt on List<dynamic> {
  Vector2 toVector2() {
    return Vector2.array(map((e) {
      if (e is int) {
        return e.toDouble();
      } else {
        return e as double;
      }
    }).toList(growable: false));
  }

  List<Vector2>? toVector2List() {
    return length < 3
        ? null
        : map((e) => (e as List<dynamic>).toVector2()).toList(growable: false);
  }

  Anchor toAnchor() {
    return Anchor(this[0], this[1]);
  }
}

extension SerdeNullListExt on List<dynamic>? {
  Vector2? toVector2() => this?.toVector2();
}

// extension OffSetExt on Offset {
//
//   Vector2 toVector2() {
//     return Vector2(dx, dy);
//   }
// }

// extension MyShapeExt on PolygonComponent {
//   MyShape toShape() {
//     final anchorVec = anchor.toVector2()..multiply(size);
//     final _relativeVertices =
//         vertices.map((e) => e.clone() - anchorVec).toList(growable: false);
//     return MyPolygonShape(
//       _relativeVertices,
//       position: position,
//     );
//   }
// }
