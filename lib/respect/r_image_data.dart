part of 'index.dart';

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
      srcSize: json.getList('srcSize').toVector2(),
    );
  }

  Image get image => Flame.images.fromCache(path);

}
