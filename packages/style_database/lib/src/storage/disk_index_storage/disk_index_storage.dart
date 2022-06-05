/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE,
 *    Version 3 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       https://www.gnu.org/licenses/agpl-3.0.en.html
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import 'dart:io';


class DiskIndexStorage {
  void init() {

    //print(String.fromCharCodes(jsonSer.codeUnits));

    // var f = File(
    //     'C:\\projects\\style\\packages\\style_database\\data\\index_col.sdi');
    // if (f.existsSync()) {
    //   f.deleteSync();
    // }
    // f.createSync();
    // var randomAccess = f.openSync(mode: FileMode.write);
    //
    // randomAccess.writeFromSync([80, 81, 85, 90, 95 , 60 , 65 , 90 , 92]);
    //
    // // randomAccess.setPositionSync(5);
    // //
    // // randomAccess.writeStringSync('b' * 3);
    // //
    // // randomAccess.writeStringSync('ali');
    //
    // randomAccess.flushSync();
    //
    // var l = List.generate(4, (index) => 0);
    // var r = randomAccess.readIntoSync([90,0,5,4],0,4);
    // randomAccess.flushSync();
    // print(r);
    // print(l);
    //
    // return;
  }

  ///
  void read() {
    ///
    var f = File(
        'C:\\projects\\style\\packages\\style_database\\data\\index_col.sdi');

    ///
    f.readAsLinesSync();

    ///
    var l = f.readAsStringSync().split(String.fromCharCode(0));

    ///
    print(l);

    ///
    print(l[1] == '');

    ///
  }

  ///

}
