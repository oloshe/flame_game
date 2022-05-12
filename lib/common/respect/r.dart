part of '../../common.dart';

class R {
  R._();

  static late _RImage images;

  static late _RAnimationName animations;

  static late RMapGlobal _map;

  static late AnimationDataMap _animationDataMap;

  static late ImageDataMap _imagePathAliasMap;

  static late TileDataIdMap _tileDataIdMap;

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
        await _initWithIntKey('json/tile.json', RTileData.fromJson);

    // 加载地图数据
    _map = await RMapGlobal.fromFile();

    // 加载所有图片资源
    images = _RImage();

    // 所有的动画名字
    animations = _RAnimationName();
  }

  /// 通过别名加载图片
  static Future<Image> _loadByAlias(String alias) async {
    return await Flame.images.load(_imagePathAliasMap[alias]!.path);
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

  static Future<Image> getTileImage(int id) async {
    return getImageByAlias(getTileById(id)!.pic);
  }

  static List<MapEntry<int, RTileData>> getAllTiles() {
    return _tileDataIdMap.entries.toList(growable: false);
  }
}

Future<Map<String, T>> _initWith<T>(String filePath,
    T Function(Map<String, dynamic> contructor) constructor) async {
  final jsonData = await Flame.assets.readJson(filePath);
  return jsonData.map(
    (key, value) => MapEntry(key, constructor(value)),
  );
}

Future<Map<int, T>> _initWithIntKey<T>(String filePath,
    T Function(Map<String, dynamic> contructor) constructor) async {
  final jsonData = await Flame.assets.readJson(filePath);
  return jsonData.map(
    (key, value) => MapEntry(int.parse(key), constructor(value)),
  );
}
