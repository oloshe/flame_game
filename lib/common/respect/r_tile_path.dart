const int topLeft = 128; // 0b1000_0000;
const int topRight = 64; // 0b0100_0000;
const int bottomLeft = 32; // 0b0010_0000;
const int bottomRight = 16; // 0b0001_0000;
const int top = 8; // 0b0000_1000;
const int right = 4; // 0b0000_0100;
const int bottom = 2; // 0b0000_0010;
const int left = 1; // 0b0000_0001;
const int full = 0; // 0b0000_0000;
const int none = -1;
const int allBottom = bottomLeft | bottom | bottomRight;
const int allTop = topLeft | top | topRight;
const int allRight = topRight | right | bottomRight;
const int allLeft = topLeft | left | bottomLeft;
const int topBottom = top | bottom;
const int all = 255;

enum PathAdjective {
  /// 9宫格
  topLeftEdge(right | bottom | bottomRight),
  topEdge(left | right | allBottom),
  topRightEdge(left | bottomLeft | bottom),
  leftEdge(topBottom | allRight),
  center(full),
  rightEdge(allLeft | top | bottom),
  bottomLeftEdge(top | topRight | right),
  bottomEdge(allTop | left | right),
  bottomRightEdge(top | left | topRight),

  verticalTop(bottom),
  vertical(topBottom),
  verticalBottom(top),

  horizontalLeft(right),
  horizontal(left | right),
  horizontalRight(left),

  bottomRightCorner(all ^ bottomRight),
  bottomLeftCorner(all ^ bottomLeft),
  topRightCorner(all ^ topRight),
  topLeftCorner(all ^ topLeft),

  empty(none),

  ;final int value;
  const PathAdjective(this.value);

  static PathAdjective fromStr(String str) {
    switch(str) {
      case 'topLeftEdge':
        return PathAdjective.topLeftEdge;
      case 'topEdge':
        return PathAdjective.topEdge;
      case 'topRightEdge':
        return PathAdjective.topRightEdge;
      case 'leftEdge':
        return PathAdjective.leftEdge;
      case 'center':
        return PathAdjective.center;
      case 'rightEdge':
        return PathAdjective.rightEdge;
      case 'bottomLeftEdge':
        return PathAdjective.bottomLeftEdge;
      case 'bottomEdge':
        return PathAdjective.bottomEdge;
      case 'bottomRightEdge':
        return PathAdjective.bottomRightEdge;
      case 'verticalTop':
        return PathAdjective.verticalTop;
      case 'vertical':
        return PathAdjective.vertical;
      case 'verticalBottom':
        return PathAdjective.verticalBottom;
      case 'horizontalLeft':
        return PathAdjective.horizontalLeft;
      case 'horizontal':
        return PathAdjective.horizontal;
      case 'horizontalRight':
        return PathAdjective.horizontalRight;
      case 'bottomRightCorner':
        return PathAdjective.bottomRightCorner;
      case 'bottomLeftCorner':
        return PathAdjective.bottomLeftCorner;
      case 'topRightCorner':
        return PathAdjective.topRightCorner;
      case 'topLeftCorner':
        return PathAdjective.topLeftCorner;
      case 'empty':
        return PathAdjective.empty;
      default: return PathAdjective.center;
    }
  }
}

class RTilePath {}

///
/// | 1 | 5 | 2 |
///
/// | 8 | X | 6 |
///
/// | 3 | 7 | 4 |
///
class RPathDirection {

  static int allConnect = 15; // 0b0000_1111
  static int allCorner = 240; // 0b1111_0000

  final int number;
  RPathDirection.number(this.number);
  RPathDirection(String number) : number = int.parse(number, radix: 2);


  bool get isNone => number == 0;

  /// 是否跟中心有连接
  bool get isConnected => number | allConnect != 0;

  /// 是否没有角落
  bool get noCorner => (number | allCorner) >> 4 == 0;

  bool get haveTopLeft => number & topLeft == topLeft;
  bool get haveTopRight => number & topRight == topRight;
  bool get haveBottomLeft => number & bottomLeft == bottomLeft;
  bool get haveBottomRight => number & bottomRight == bottomRight;

  RPathDirection operator |(RPathDirection other) {
    return RPathDirection.number(number | other.number);
  }
}

class RPathUnit {
  final int count;
  final RPathDirection direction;
  RPathUnit(this.count, String number) : direction = RPathDirection(number);

  bool get isSingle => count == 1;
}
