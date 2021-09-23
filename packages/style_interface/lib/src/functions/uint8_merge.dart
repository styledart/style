import 'dart:typed_data';

///
Uint8List mergeList(List<Uint8List> list) {
  var uint = <int>[];
  for (var _a in list) {
    uint.addAll(_a);
  }
  return Uint8List.fromList(uint);
}