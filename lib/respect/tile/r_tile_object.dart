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
    required Rect? displayRect,
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
          displayRect: displayRect,
        );

  static initObjectBuilder() {
    _tileObjectMap = {
      "skeleton": (tileObject, position) async {
        return Skeleton(tileObject)..position = position;
      },
      "player": (tileObject, position) async {
        return Player(tileObject)..position = position;
      },
      "slime": (tileObject, position) async {
        return Slime(tileObject)..position = position;
      }
    };
  }

  Vector2 get srcSize => R.getImageData(pic).srcSize;

  RTileObjectMapValue buildObject(Vector2 position) {
    return RTileObject._tileObjectMap[name]?.call(this, position);
  }

  /// 创建这个对象的动作组组件
  Future<SpriteAnimationGroupComponent<T>> buildAnimationGroup<T extends Enum>({
    required List<T> allValues,
    required T initialValue,
    Set<T>? removeOnFinish,
  }) async {
    return SpriteAnimationGroupComponent<T>(
      animations: await R.createAnimations(allValues, name),
      current: initialValue,
      size: spriteSize,
      anchor: anchor ?? Anchor.center,
      removeOnFinish: removeOnFinish != null
          ? Map.fromEntries(removeOnFinish.map((e) => MapEntry(e, true)))
          : null,
    );
  }

  @override
  String toString() {
    return 'TileObject<$name>: ${super.toString()}';
  }
}

typedef RTileObjectMapValue = FutureOr<PositionComponent?>;

typedef RTileObjectMapFunction = RTileObjectMapValue Function(
    RTileObject tileObject, Vector2 position);

typedef TileObjectMap = Map<String, RTileObjectMapFunction>;
