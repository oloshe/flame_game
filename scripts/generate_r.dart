import 'dart:convert';
import 'dart:io';

void main() async {
  // await generateImgAlias();
  await generateAnimation();
}

Future<void> generateImgAlias() async {
  final imageAliasStr =
      await File('assets/json/image_alias.json').readAsString();
  final Map<String, dynamic> json = jsonDecode(imageAliasStr);
  final fields = json.entries
      .map((e) => "  final ${e.key} = R._loadByAlias('${e.key}');")
      .join('\n');
  final str = _buildFileHeader() + 'class _RImage {\n$fields\n}\n';

  await finishFile('r_image.dart', str, 'image alias');
}

Future<void> generateAnimation() async {
  final animationJsonStr =
      await File('assets/json/animation.json').readAsString();
  final Map<String, dynamic> json = jsonDecode(animationJsonStr);
  String enumStr = _buildFileHeader();
  json.forEach((key, value) {
    String? enumName = value['enum'];
    if (enumName != null) {
      final names = Map.from(value['animations'])
          .entries
          .map((e) => '  ${e.key},')
          .join('\n');
      enumStr += 'enum $enumName {\n$names\n}\n';
    }
  });
  await finishFile('enums.dart', enumStr, 'enums文件');

  String aniStr = _buildFileHeader();
  final aniListToStr =
      json.entries.map((e) => "  final ${e.key} = '${e.key}';").join('\n');
  aniStr += "class _RAnimationName {\n$aniListToStr\n}\n";

  await finishFile('r_animation_name.dart', aniStr, 'animation name 文件');
}

String _buildFileHeader() {
  return "part of '../../common.dart';\n\n";
}

Future<void> finishFile(String destFileName, String data,
    [String? nameCn]) async {
  final destFilePath = 'lib/common/generated/$destFileName';
  await File(destFilePath).writeAsString(data);
  print('${nameCn ?? ''}已生成：file://${Directory.current.path}/$destFilePath');
}
