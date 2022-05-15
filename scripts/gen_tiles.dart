void main() {
  var startId = 137;
  var amountPerRow = 8;
  var row = 6;
  Set<int> jumpIndex = {6, 7, 10, 14, 15, 20, 21, 22, 23, 28,29,30,31,38,39,46,47};
  const pic = 'walls';
  const type = 'walls';
  final amount = row * amountPerRow;
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