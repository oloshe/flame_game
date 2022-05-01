import 'dart:math' as math;

void main() {
  var startId = 2;
  var amountPerRow = 6;
  var row = 12;
  Set<int> jumpIndex = {22, 23, 46, 47, 70, 71};
  const pic = 'plains';
  const type = 'plains';
  final amount = 12 * amountPerRow;
  var ret = '';
  for(var i = 0; i < amount; i++) {
    if (jumpIndex.contains(i)) {
      continue;
    }
    ret += '''\n  "${startId + i}": {
    "pic": "$pic",
    "type": "$type",
    "pos": [${i%amountPerRow}, ${(i/amountPerRow).floor()}]
  },''';
  }
  print(ret);
}