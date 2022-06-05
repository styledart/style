


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

void main() {



}

// /*
//  * Copyright 2021 styledart.dev - Mehmet Yaz
//  *
//  * Licensed under the Apache License, Version 2.0 (the "License");
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  *       http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an "AS IS" BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  *
//  */
//
// import 'dart:convert';
// import 'dart:html';
// import 'dart:math';
// import 'dart:typed_data';
//
// import 'package:style_database/src/object/object.dart';
//
// void main() {
//   var m = {
//     'int': 8,
//     'int8': 16,
//     // 'int32': 1526,
//     // 'bool': true,
//     //'bool_data': BoolData(false),
//     // 'float_32': Float32Data(16.846),
//     // 'float_64': Float64Data(1455.55468),
//     //'float': 186.56161,
//     // 'matrix': [
//     //   [1, 2, 3],
//     //   [4, 5, 6],
//     //   [7, 8, 9]
//     // ],
//     // 'null': null,
//     // 'null_data': NullData(),
//     // 'uint32list': Uint32ListData([86, 118, 68, 99, 65, 210, 186, 135, 145]),
//     // 'list_st': FixedLengthStringList(<String>['AA', 'BB', 'CC'], 2),
//     // 'list_int': <int>[
//     //   151,
//     //   46,
//     //   543,
//     //   546,
//     //   846,
//     //   11,
//     //   51,
//     //   3,
//     //   16,
//     //   5,
//     //   3,
//     //   216,
//     //   48,
//     //   65,
//     //   68,
//     //   9,
//     //   68,
//     //   4,
//     //   1,
//     //   6541,
//     //   5,
//     //   46,
//     //   5,
//     //   46,
//     //   4,
//     //   654,
//     //   54,
//     //   6,
//     //   54,
//     //   65,
//     // ],
//   };
//
//   var i = 0;
//
//   var st = Stopwatch()..start();
//   while (i < 1000000) {
//     StyleMap(m);
//     i++;
//   }
//
//   print(st.elapsedMicroseconds / 1000000);
//
//   // print(StyleMap.getSignedInt8(191));
//   //
//   // // var a = 18;
//   // // Int64();
//   // //
//   // // var mask = (1 << 7) - 1;
//   // // print(mask);
//   // // print(mask & ~a);
//   // // print(~a);
//   // // print(a & (1 << 7));
//   //
//   // return;
//   //
//   // //
//   // // var list = <int>[];
//   // //
//   // // var i = 0;
//   // //
//   // // while(i < 50) {
//   // //
//   // //   list.addAll([
//   // //     52, 0, 0, //set obj len
//   // //     86, 87, 89, 80,
//   // //     0, // next
//   // //     1, //set entry type,
//   // //     3, 0, 0, //set entry key len
//   // //     65, 65, 65, // aaa
//   // //     // null
//   // //     0, // next
//   // //     2, //set entry type,
//   // //     3, 0, 0, //set entry key len
//   // //     66, 66, 66, // bbb,
//   // //     16, // byt value
//   // //     //20
//   // //     0, // next
//   // //     3, // entry type
//   // //     3, 0, 0, // set entry_key_len
//   // //     67, 67, 67, // key
//   // //     5, 0, 0, // value len
//   // //     65, 66, 67, 68, 69, // value
//   // //     //40
//   // //     0, // next
//   // //     4, // type
//   // //     5, 0, 0, // key len
//   // //     65, 66, 67, 68, 69,
//   // //     58, 0
//   // //   ]);
//   // //
//   // //   i++;
//   // // }
//   //
//   // // print(list[52]);
//   // // print(list[0]);
//   // // print(list[52 * 4]);
//   // // print(list.sublist(52 * 5 , 52 * 6));
//   // // print(list[52 * 10]);
//   // // print(list[52 * 35]);
//   // // print(list[52 * 40]);
//   //
//   // /// small docs (1kb)
//   // ///   ~0.8 µs disk read
//   // ///   ~0.05 µs query
//   // ///   total: ~0.85 µs
//   // ///
//   // ///
//   // /// long docs (5kb)
//   // ///
//   //
//   // var i = 0;
//   //
//   // var file = File(
//   //     'C:\\projects\\style\\packages\\style_database\\data\\index_col.sdi');
//   //
//   // var randomAccess = file.openSync();
//   //
//   // //
//   // var r = Random();
//   //
//   // var st = Stopwatch()..start();
//   // var res = 0;
//   // while (i < 100000) {
//   //   var o = r.nextInt(15000) * 52;
//   //   randomAccess.setPositionSync(o);
//   //   // var read = randomAccess.readSync(3);
//   //   // var l = Int64.fromBytes([
//   //   //   ...read,
//   //   //   0,0,0,0,0
//   //   // ]).toInt();
//   //   // randomAccess.setPositionSync(o);
//   //   var f = randomAccess.readSync(520);
//   //   var d = StyleMap.parse(f);
//   //
//   //   st.stop();
//   //   i++;
//   // }
//   // res += st.elapsedMicroseconds;
//   //
//   // print(res / 100000);
//   // print(1000000 ~/ (res / 100000));
//
//   //
//   //
//   // var sink = file.openWrite();
//   //
//   // while (i < 200000) {
//   //   sink.add([
//   //     52, 0, 0, //set obj len
//   //     86, 87, 89, 80,
//   //     0, // next
//   //     1, //set entry type,
//   //     3, 0, 0, //set entry key len
//   //     65, 65, 65, // aaa
//   //     // null
//   //     0, // next
//   //     2, //set entry type,
//   //     3, 0, 0, //set entry key len
//   //     66, 66, 66, // bbb,
//   //     16, // byt value
//   //     //20
//   //     0, // next
//   //     3, // entry type
//   //     3, 0, 0, // set entry_key_len
//   //     67, 67, 67, // key
//   //     5, 0, 0, // value len
//   //     65, 66, 67, 68, 69, // value
//   //     //40
//   //     0, // next
//   //     4, // type
//   //     5, 0, 0, // key len
//   //     65, 66, 67, 68, 69,
//   //     58, 0
//   //   ]);
//   //   i++;
//   // }
//   //
//   //
//   // return;
//
//   // var r = {
//   //   '__id': 'VWYP',
//   //   'AAA': null,
//   //   'BBB': 16,
//   //   'CCC': [65, 66, 67, 68, 69]
//   // };
//   //
//   // print(json.encode(r).codeUnits.length);
//   //
//   // var parsed = StyleMap.parse([
//   //   52, 0, 0, //set obj len
//   //   86, 87, 89, 80,
//   //   0, // next
//   //   1, //set entry type,
//   //   3, 0, 0, //set entry key len
//   //   65, 65, 65, // aaa
//   //   // null
//   //   0, // next
//   //   2, //set entry type,
//   //   3, 0, 0, //set entry key len
//   //   66, 66, 66, // bbb,
//   //   16, // byt value
//   //   //20
//   //   0, // next
//   //   3, // entry type
//   //   3, 0, 0, // set entry_key_len
//   //   67, 67, 67, // key
//   //   5, 0, 0, // value len
//   //   65, 66, 67, 68, 69, // value
//   //   //40
//   //   0, // next
//   //   4, // type
//   //   5, 0, 0, // key len
//   //   65, 66, 67, 68, 69,
//   //   58, 0
//   // ]);
//   //
//   // print(parsed.data);
//
//   ///
//   /// Index storage size
//   ///
//   /// 1M INT
//   ///
//   /// Unique
//   ///       disk :  1M * 8       =  8MB
//   ///       mem  :  1M * 8       =  8MB
//   ///
//   /// Duplicated
//   ///       disk :  1M * (8 + 8) =  16MB
//   ///       mem  :  1M * 8       =  8MB
//   ///
//   ///
//   ///
//   /// 1M String
//   /// Avg. len: 20
//   ///
//   /// Unique
//   ///       disk :  1M * 3        = 3MB
//   ///       disk :  1M * 20       = 20MB
//   ///       mem  :  1M * 8        = 8MB
//   ///
//   /// Duplicated
//   ///       disk :  1M * (8 + 20) = 28MB
//   ///       mem  :  1M * 8        = 8M
//   ///
//
//   // var i32 = fx.Int32.parseHex('FFFFFF');
//   //
//   // print(i32.toUnsigned(24).toBytes());
//   //
//   // print(fx.Int64.fromBytes(([255, 255, 255, 0, 0, 0, 0, 0])));
//   //
//   //
//   // return;
//
//   // var st = DiskIndexStorage();
//   //
//   // st.init();
//
//   // st.read();
// }
//
