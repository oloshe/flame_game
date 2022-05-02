part of '../common.dart';

class I18N with material.ChangeNotifier {
  final Map<String, dynamic> json;
  late final List<String> lang;
  late Map<String, String> dictionary;

  I18N._(this.json) {
    lang = List.from(json['lang'])
        .map((e) => e.toString())
        .toList(growable: false);
    dictionary =
        Map.from(json[lang[0]]).map((key, value) => MapEntry(key, value));
  }

  static Future<I18N> create() async {
    final json = await Flame.assets.readJson('json/i18n.json');
    final instance = I18N._(json);
    return instance;
  }

  void changeLang(String language) {
    if (json[language] != null) {
      dictionary =
          Map.from(json[language]).map((key, value) => MapEntry(key, value));
      notifyListeners();
    } else {
      Fluttertoast.showToast(msg: '没有该语言！');
    }
  }
}

late I18N i18n;

extension I18NExt on String {
  String get lang {
    return i18n.dictionary[this] ?? this;
  }

  String get langWatch {
    return MyApp.navKey.currentContext!.watch<I18N>().dictionary[this] ?? this;
  }

  String args(String arg, Object value) {
    return replaceAll('\$$arg', value.toString());
  }
}
