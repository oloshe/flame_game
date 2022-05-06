import 'dart:convert';
import 'dart:io';

void main() async {
  final tileStr = await File('assets/json/tile.json').readAsString();
  final Map<String, dynamic> tileJson =
      (jsonDecode(tileStr) as Map<String, dynamic>);
  final entriesList = tileJson.entries.toList(growable: false);
  final Map<String, dynamic> result = Map.fromEntries(
    List.generate(
      tileJson.length,
      (index) {
        final value = entriesList[index].value;
        if (value['pos'] != null) {
          int x = value['pos'][0];
          int y = value['pos'][1];
          value['pos'] = double.parse("$x.$y");
        }
        return MapEntry((index + 1).toString(), value);
      },
    ),
  );
  print(prettyJson(result));
}

String prettyJson(dynamic json) {
  var encoder = JsonEncoder.withIndent(' ' * 2);
  return encoder.convert(json);
}
