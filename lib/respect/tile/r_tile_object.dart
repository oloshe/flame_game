part of '../index.dart';

class RTileObject extends RTileHit {
  static late TileObjectMap _tileObjectMap;

  /// tile 名 主要用于对象创建时的区分
  final String name;
  RTileObject({
    required this.name,
    required List<Vector2>? polygon,
    required Anchor? anchor,
    required String pic,
    required int id,
    required int x,
    required int y,
    required int w,
    required int h,
    required String type,
    required String? subType,
    required List<int>? combines,
  }) : super(
          polygon: polygon,
          anchor: anchor,
          id: id,
          type: type,
          subType: subType,
          x: x,
          y: y,
          w: w,
          h: h,
          pic: pic,
          combines: combines,
        );

  static initObjectBuilder() {
    _tileObjectMap = {
      "skeleton": (tileData, position) async {
        return Skeleton()..position = position;
      }
    };
  }

  RTileObjectMapValue buildObject(Vector2 position) {
    return RTileObject._tileObjectMap[name]?.call(this, position);
  }

  @override
  String toString() {
    return 'TileObject($name)->${super.toString()}';
  }
}

typedef RTileObjectMapValue = FutureOr<PositionComponent?>;

typedef RTileObjectMapFunction = RTileObjectMapValue Function(
    RTileBase tileData, Vector2 position);

typedef TileObjectMap = Map<String, RTileObjectMapFunction>;
