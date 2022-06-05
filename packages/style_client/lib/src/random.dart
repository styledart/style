/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

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
