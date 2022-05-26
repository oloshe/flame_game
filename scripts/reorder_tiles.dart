import 'dart:convert';
import 'dart:io';

void main() async {
  final tileStr = await File('assets/json/terrains/hill.json').readAsString();
  const offset = 51;
  final Map<String, dynamic> tileJson =
      (jsonDecode(tileStr) as Map<String, dynamic>);
  final entriesList = tileJson.entries.toList(growable: false);
  final Map<String, dynamic> result = Map.fromEntries(
    List.generate(
      tileJson.length,
      (index) {
        final value = entriesList[index].value;
        // if (value['pos'] != null) {
        //   value['pos'] = {"x": value['pos'][0], "y": value['pos'][1]};
        // }
        return MapEntry((index + offset).toString(), value);
      },
    ),
  );
  print(prettyJson(result));
}

String prettyJson(dynamic json) {
  var encoder = JsonEncoder.withIndent(' ' * 2);
  return encoder.convert(json);
}
