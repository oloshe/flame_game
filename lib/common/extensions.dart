part of '../common.dart';

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

// extension OffSetExt on Offset {
//
//   Vector2 toVector2() {
//     return Vector2(dx, dy);
//   }
// }

