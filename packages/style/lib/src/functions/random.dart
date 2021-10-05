
import 'dart:math';

///Get random id defined length
String getRandomId(int len) {
  var _characters =
      'ABCDEFGHIJKLMNOPRSTUQYZXWabcdefghijqklmnoprstuvyzwx0123456789';
  var _listChar = _characters.split('');
  var _lentList = _listChar.length;
  var _randId = <String>[];

  for (var i = 0; i < len; i++) {
    var _randNum = Random();
    var _r = _randNum.nextInt(_lentList);
    _randId.add(_listChar[_r]);
  }
  var id = StringBuffer();
  for (var c in _randId) {
    id.write(c);
  }
  return id.toString();
}
