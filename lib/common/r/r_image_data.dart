part of '../../common.dart';

typedef ImageDataMap = Map<String, RImageData>;

class RImageData {
  final String path;
  final Vector2? srcSize;
  RImageData({
    required this.path,
    required this.srcSize,
  });

  factory RImageData.fromJson(Map<String, dynamic> json) {
    return RImageData(
      path: json['path'],
      srcSize: utils.vec2Field(json['srcSize']),
    );
  }

  Future<Image> get image async => await Flame.images.load(path);
}
