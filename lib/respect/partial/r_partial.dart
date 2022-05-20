import 'package:game/respect/index.dart';
import 'package:game/respect/partial/r_partial_terrain.dart';

enum PartialType {
  terrain,
}

class RPartial with RPartialData {
  PartialType type;
  String source;
  RPartialData data;

  RPartial({
    required this.type,
    required this.source,
    required this.data,
  });

  factory RPartial.fromJson(Map<String, dynamic> json) {
    final type = _partialTypeFromString(json["type"]);
    return RPartial(
      type: type,
      source: json["source"],
      data: RPartialData.fromJson(json["data"], type),
    );
  }

  @override
  void supplement(Map<String, dynamic> json) {
    data.supplement(json);
  }

  @override
  void process(RTileBase tileBase, Map<String, dynamic> json) {
    data.process(tileBase, json);
  }
}

PartialType _partialTypeFromString(String type) {
  switch (type) {
    case "terrain":
      return PartialType.terrain;
    default:
      throw UnimplementedError();
  }
}

mixin RPartialData {
  static RPartialData fromJson(Map<String, dynamic> json, PartialType type) {
    switch (type) {
      case PartialType.terrain:
        return RPartialTerrain.fromJson(json);
      default:
        throw UnimplementedError();
    }
  }

  /// 补充省略的json字段
  void supplement(Map<String, dynamic> json) {}

  /// 反序列化之后处理相关数据
  void process(RTileBase tileBase, Map<String, dynamic> json) {}
}
