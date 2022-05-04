import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:game/common.dart';

class Translations with ChangeNotifier {
  final List<Locale> supportLang;
  final Map<Locale, Map<String, String>> keys;

  Locale locale;

  /// 当前语言。使用的时候读取系统默认语言
  late Map<String, String> dictionary;

  Translations._internal({
    required this.supportLang,
    required this.keys,
    this.locale = const Locale('zh', 'CN'),
  }) {
    dictionary = keys[locale]!;
  }

  static late Translations instance;

  static Future<Translations> getInstance() async {
    final json = await Flame.assets.readJson('json/i18n.json');
    List<dynamic> _lang = json.remove('lang');
    final lang = _lang.map((e) => utils.str2Locale(e)).toList(growable: false);
    final i18n = Translations._internal(
      supportLang: lang,
      keys: json.map(
        (key, value) => MapEntry(
          utils.str2Locale(key),
          Map.from(value).map((key, value) => MapEntry(key, value)),
        ),
      ),
    );
    instance = i18n;
    return i18n;
  }

  void updateLocale(Locale newLocale) {
    final key = newLocale.toString();
    if (keys.containsKey(key)) {
      locale = newLocale;
      dictionary = keys[key]!;
      notifyListeners();
    } else {
      // 提示没有该语言
    }
  }

  String translate(String key) => dictionary[key] ?? key;
}
