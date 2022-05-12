part of '../../common.dart';

class _Utils {
  final Paint painter = Paint()
    ..color = const Color(0x55ffffff)
    ..strokeWidth = 2
    ..style = PaintingStyle.fill;

  material.Locale str2Locale(String str) {
    final arr = str.split('_');
    return material.Locale(arr[0], arr[1]);
  }
}

final _Utils utils = _Utils();
