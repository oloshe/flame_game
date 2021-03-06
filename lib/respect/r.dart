part of 'index.dart';

class R {
  R._();

  static const jsonPath = "json/";

  static late RMapGlobal _map;

  static late AnimationDataMap _animationDataMap;

  static late ImageDataMap _imagePathAliasMap;

  static late TileDataIdMap _tileDataIdMap;

  static late TileObjectMap _tileObjectMap;

  static RMapGlobal get mapMgr => _map;

  // 初始化资源
  static Future<void> init() async {
    // 加载图片别名配置
    _imagePathAliasMap =
        await _initWith('json/image_alias.json', RImageData.fromJson);

    // 加载动画
    _animationDataMap =
        await _initWith('json/animation.json', RAnimationData.fromJson);

    // 加载tile
    _tileDataIdMap =
        await RTileData.load();

    // 加载地图数据
    _map = await RMapGlobal.fromFile();

    _tileObjectMap = {
      "skeleton": (tileData, position) async {
        return Skeleton()..position = position;
      }
    };
  }

  /// 根据别名获取图片的配置数据
  static RImageData getImageData(String alias) {
    return _imagePathAliasMap[alias]!;
  }

  static Future<Image> getImageByAlias(String alias) async {
    return _imagePathAliasMap[alias]!.image;
  }

  /// 根据动画名字获取动画配置数据
  static RAnimationData getAnimationData(String animationName) {
    return _animationDataMap[animationName]!;
  }

  /// 传入动画枚举，返回动画组，配合 [SpriteAnimationGroupComponent] 使用
  static Future<Map<T, SpriteAnimation>> createAnimations<T extends Enum>(
    List<T> enumValues,
    String name,
  ) async {
    final animationData = getAnimationData(name);
    return animationData.getAnimationsMap(enumValues, name);
  }

  static RTileData? getTileById(int id) {
    return _tileDataIdMap[id];
  }

  // static Future<Image> getTileImage(int id) async {
  //   return getImageByAlias(getTileById(id)!.pic!);
  // }

  static List<MapEntry<int, RTileData>> getAllTiles() {
    return _tileDataIdMap.entries.toList(growable: false);
  }

  static RTileObjectMapFunction? getTileObjectBuilder(String? objectName) {
    return _tileObjectMap[objectName];
  }
}

Future<Map<String, T>> _initWith<T>(String filePath,
    T Function(Map<String, dynamic> contructor) constructor) async {
  final jsonData = await Flame.assets.readJson(filePath);
  return jsonData.map(
    (key, value) => MapEntry(key, constructor(value)),
  );
}

typedef RTileObjectMapValue = FutureOr<PositionComponent?>;

typedef RTileObjectMapFunction = RTileObjectMapValue Function(
    RTileData tileData, Vector2 position);

typedef TileObjectMap = Map<String, RTileObjectMapFunction>;
