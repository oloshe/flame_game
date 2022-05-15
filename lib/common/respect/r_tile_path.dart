class RTilePath {
  static RPathDirection topLeft = RPathDirection("1000_0000");
  static RPathDirection topRight = RPathDirection("0100_0000");
  static RPathDirection bottomLeft = RPathDirection("0010_0000");
  static RPathDirection bottomRight = RPathDirection("0001_0000");
  static RPathDirection topCenter = RPathDirection("0000_1000");
  static RPathDirection right = RPathDirection("0000_0100");
  static RPathDirection bottomCenter = RPathDirection("0000_0010");
  static RPathDirection left = RPathDirection("0000_0001");
}

///
/// | 1 | 5 | 2 |
///
/// | 8 | X | 6 |
///
/// | 3 | 7 | 4 |
///
class RPathDirection {
  final int number;
  RPathDirection(String number) : number = int.parse(number, radix: 2);

  /// 是否跟中心有连接
  bool get isConnected {
    // 15 => 1111
    return number | 15 != 0;
  }
}

class RPathUnit {
  final int count;
  final RPathDirection direction;
  RPathUnit(this.count, String number) : direction = RPathDirection(number);

  bool get isSingle => count == 1;
}
