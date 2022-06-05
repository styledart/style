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

import 'dart:convert';
import 'dart:typed_data';

import 'package:style_object/style_object.dart';

// void main() {
//   var mapper =
//       ObjectKeyMapper(keys: {"count_1": Int8Key(1), "count_2": Int8Key(2)});
//
//   var codec = StyleObjectCodec(keyMapper: mapper);
//
//   var converter = codec.encoder;
//   var decoder = codec.decoder;
//
//   var byte = Uint8List.fromList([
//     //object key
//     0, 0,
//
//     // object entry count
//     0, 2,
//     // first entry key - value
//     0, 1, 30,
//     // second entry key - value
//     0, 2, 30
//   ]).buffer.asByteData();
//
//   var ii = 0;
//   while (ii < 10) {
//     var i = 0;
//     var st = Stopwatch()..start();
//
//     while (i < 1000000) {
//       decoder.convert(byte);
//       i++;
//     }
//     st.stop();
//     print(st.elapsedMicroseconds / 1000000);
//     ii++;
//   }
//
//   return;
//
//   // print(converter
//   //     .convert(StyleObject({
//   //       Int8Key(1): Int8Data(30),
//   //       Int8Key(2): Int8Data(30),
//   //     }))
//   //     .buffer
//   //     .asUint8List());
//   // var ii = 0;
//   // while (ii < 10) {
//   //   var i = 0;
//   //   var st = Stopwatch()..start();
//   //
//   //   while (i < 1000000) {
//   //     converter.convert(StyleObject({
//   //       Int8Key(1): Int8Data(30),
//   //       Int8Key(2): Int8Data(30),
//   //     }));
//   //     i++;
//   //   }
//   //   st.stop();
//   //   print(st.elapsedMicroseconds / 1000000);
//   //   ii++;
//   // }
//   //
//   // print("json_bytes: ${json.encode({
//   //           "count_1": 30,
//   //           "count_2": 30,
//   //           "count_3": 18645156113,
//   //           "count_4": 18645156113
//   //         }).codeUnits.length}");
//   // print((st.elapsedMicroseconds / 1000000) /* + 0.1 + 0.2*/);
//   // print(
//   //     "in sec: ${1000000 ~/ (st.elapsedMicroseconds / 1000000)} count" /* + 0.1 + 0.2*/);
// }

// void main() {
//   var byteData = ByteData(100000);
//
//   var l = utf8.encode('Style Object Created by Mehmet Yaz' * 10);
//   var i = 0;
//   var st = Stopwatch()..start();
//
//   while (i < 1000000) {
//     byteData = withByteData(byteData, l);
//     //withLoop(byteData, l);
//     i++;
//   }
//   print(byteData.offsetInBytes);
//   print(st.elapsedMicroseconds / 1000000);
// }

ByteData withByteData(ByteData data, List<int> value) {
  var b = data.buffer.asUint8List()
    ..setRange(0, value.length, Uint8List.fromList(value).buffer.asUint8List());
  return b.buffer.asByteData();
}

void withLoop(ByteData data, List<int> value) {
  var o = 0;
  for (var v in value) {
    data.setInt64(o, v);
    o++;
  }
}

void main() {
  var a = A(
      count1: 57776545477274554,
      count2: 14665414764,
      count3: 146654,
      enumV: MyEnum.c,
      boolV: false,
      bytes: "Style".codeUnits,
      string: "Style Object Created by Mehmet Yaz");

  var codec = StyleObjectCodec(
      keyCollection: KeyCollection.withRoot(ObjectKey(0), [
    IntKey(1),
    Uint32Key(2),
    Int8Key(3),
    BoolKey(4),
    Uint8ListKey(5),
    StringKey(6),
    Int16Key(7)
  ]));

  var encoder = codec.encoder;
  var decoder = codec.decoder;

  var bytes = encoder.convert(a.toObject());
  print("How To Stored?");

  print("STYLE: Not human readable!");
  var aJson = json.encode(a.toJson()).codeUnits;
  print("JSON: ${json.encode(a.toJson())}");

  print("\nHow Much Space?");
  print("style length : ${bytes.lengthInBytes}");
  print("json length: ${aJson.length}");
  //var nA = A.fromObject(decoder.convert(bytes));

  // print(nA.x);
  // print(nA.y);
  // print(nA.e);
  // print(nA.b);
  // print(nA.bytes);
  // print(nA.string);

  var i = 0;

  var stJson = Stopwatch()..start();
  // json decode
  while (i < 1000000) {
    A.fromJson(json.decode(utf8.decode(aJson)));
    i++;
  }
  stJson.stop();

  i = 0;
  var st = Stopwatch()..start();
  // style decode
  while (i < 1000000) {
    A.fromObject(decoder.convert(bytes));
    i++;
  }
  st.stop();
  i = 0;
  var stJsonEn = Stopwatch()..start();
  // json encode
  while (i < 1000000) {
    utf8.encode(json.encode(a.toJson()));
    i++;
  }
  stJsonEn.stop();
  i = 0;

  var stEn = Stopwatch()..start();

  // Style encode
  while (i < 1000000) {
    encoder.convert(a.toObject());
    i++;
  }
  stEn.stop();

  print("\nHow Long To Encode? (dart object instance to bytes)");
  print("STYLE: ${toMicro(stEn.elapsedMicroseconds)}  μs/object");
  print("JSON: ${toMicro(stJsonEn.elapsedMicroseconds)}  μs/object");

  print("\nHow Long To Decode?  (bytes to dart object instance)");
  print("STYLE: ${toMicro(st.elapsedMicroseconds)}  μs/object");
  print("JSON: ${toMicro(stJson.elapsedMicroseconds)}  μs/object");
}

double toMicro(int elapsedMicro) {
  return ((elapsedMicro / 1000000) * 10).floor() / 10;
}

class A {
  A(
      {required this.count1,
      required this.count2,
      required this.enumV,
      required this.boolV,
      required this.bytes,
      required this.string,
      required this.count3});

  factory A.fromJson(Map<String, dynamic> map) {
    return A(
        count1: map["count_64"],
        count2: map["count_32"],
        enumV: MyEnum.values[map["enumV"]],
        boolV: map["boolV"],
        bytes: (map["bytes"] as List).cast<int>(),
        string: map["string"],
        count3: map['count_16']);
  }

  factory A.fromObject(Map<int, dynamic> obj) {
    return A(
        count1: obj[1],
        count2: obj[2],
        enumV: MyEnum.values[obj[3]],
        boolV: obj[4],
        bytes: obj[5],
        string: obj[6],
        count3: obj[7]
        /*return A(
        count1: obj[IntKey(1)],
        count2: obj[Uint32Key(2)],
        enumV: MyEnum.values[obj[Int8Key(3)]],
        boolV: obj[BoolKey(4)],
        bytes: obj[Uint8ListKey(5)],
        string: obj[StringKey(6)],
        count3: obj[Int16Key(7)]*/
        );
  }

  StyleObject toObject() => StyleObjectWithKeys({
        (1): IntData(count1),
        (2): UInt32Data(count2),
        (3): Int8Data(enumV.index),
        (4): BoolData(boolV),
        (5): Uint8ListData(bytes),
        (6): StringData(string),
        (7): Int16Data(count3)
      });

  Map<String, dynamic> toJson() => {
        "count_64": count1,
        "count_32": count2,
        "count_16": count3,
        "enumV": enumV.index,
        "boolV": boolV,
        "bytes": bytes,
        "string": string
      };

  int count1;
  int count2;
  int count3;
  MyEnum enumV;
  bool boolV;
  List<int> bytes;
  String string;
}

enum MyEnum { a, b, c, d }
