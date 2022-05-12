part of '../../common.dart';

class _Utils {

  material.Locale str2Locale(String str) {
    final arr = str.split('_');
    return material.Locale(arr[0], arr[1]);
  }
}

final _Utils utils = _Utils();
