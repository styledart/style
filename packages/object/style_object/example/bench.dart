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
  test();
  test();
  test();
  test();
  test();
  test();
  test();
  test();
}

var count = 1000000;

void test() {
  var a = A(
      count64: 4093001811601238970,
      count32: 14665414764,
      count16: 146654,
      enumV: MyEnum.c,
      boolV: true,
      bytes: utf8.encode("Styles"),
      string: "Style Object Created by Mehmet Yaz");

  var ii = 0;
  while (ii < 10) {
    var b = a.toObject();
    A.fromBytes(b);
    ii++;
  }

  var bytes = a.toObject();
  print("\n\n\nHow To Stored?");

  print("STYLE: Not human readable!");
  var jsonEncoded = utf8.encode(json.encode(a.toJson()));
  print("JSON: ${json.encode(a.toJson())}");

  print("\nHow Much Space?");
  print("style length : ${bytes.lengthInBytes}");
  print("json length: ${jsonEncoded.length}");

  print("\nHow Long To Encode? (dart object instance to bytes)");
  print("STYLE: ${toMicro(testStyleEncode(a))}  μs/object");
  print("JSON: ${toMicro(testJsonEncode(a))}  μs/object");

  print("\nHow Long To Decode?  (bytes to dart object instance)");
  print("STYLE: ${toMicro(testStyleDecode(bytes))}  μs/object");
  print(
      "JSON: ${toMicro(testJsonDecode(jsonEncoded as Uint8List))}  μs/object");
}

int testJsonEncode(A a) {
  var st = Stopwatch()..start();
  var i = 0;
  while (i < count) {
    utf8.encode(json.encode(a.toJson()));
    i++;
  }
  return st.elapsedMicroseconds;
}

int testStyleEncode(A a) {
  var st = Stopwatch()..start();
  var i = 0;
  while (i < count) {
    a.toObject();
    i++;
  }
  return st.elapsedMicroseconds;
}

int testJsonDecode(Uint8List bytes) {
  var st = Stopwatch()..start();
  var i = 0;
  while (i < count) {
    A.fromJson(json.decode(utf8.decode(bytes)));
    i++;
  }
  return st.elapsedMicroseconds;
}

int testStyleDecode(ByteData bytes) {
  var st = Stopwatch()..start();
  var i = 0;
  while (i < count) {
    A.fromBytes(bytes);
    i++;
  }
  return st.elapsedMicroseconds;
}

double toMicro(int elapsedMicro) {
  return ((elapsedMicro / count) * 10).floor() / 10;
}

class A {
  A(
      {required this.count64,
      required this.count32,
      required this.enumV,
      required this.boolV,
      required this.bytes,
      required this.string,
      required this.count16});

  factory A.fromJson(Map<String, dynamic> map) {
    return A(
        count64: map["count_64"],
        count32: map["count_32"],
        enumV: MyEnum.values[map["enumV"]],
        boolV: map["boolV"],
        bytes: (map["bytes"] as List).cast<int>(),
        string: map["string"],
        count16: map['count_16']);
  }

  factory A.fromBytes(ByteData bytes) {
    var obj = decoder.convert(bytes);
    return A(
        count64: obj[_count64.key],
        count32: obj[_count32.key],
        enumV: MyEnum.values[obj[_enum.key]],
        boolV: obj[_bool.key],
        bytes: obj[_bytes.key],
        string: obj[_string.key],
        count16: obj[_count16.key]);
  }

  static StyleObjectCodec codec = StyleObjectCodec(
      keyCollection: ObjectKey(0)
        ..addKey(_count64)
        ..addKey(_count32)
        ..addKey(_enum)
        ..addKey(_bool)
        ..addKey(_bytes)
        ..addKey(_string)
        ..addKey(_count16));

  static StyleObjectEncoder encoder = codec.encoder;
  static StyleObjectDecoder decoder = codec.decoder;

  static final _count64 = IntKey(1);
  static final _count32 = Uint32Key(2);
  static final _count16 = Int16Key(7);
  static final _enum = Int8Key(3);
  static final _bool = BoolKey(4);
  static final _bytes = Uint8ListKeyWithTyped(5, 6);
  static final _string = StringKey(6, 34);

  ByteData toObject() => encoder.convert(StyleObjectAdvanced({
        _count64: IntData(count64),
        _count32: UInt32Data(count32),
        _enum: Int8Data(enumV.index),
        _bool: BoolData(boolV),
        _bytes: Uint8ListDataWithTyped(bytes as Uint8List),
        _string: StringData(string),
        _count16: Int16Data(count16)
      }));

  Map<String, dynamic> toJson() => {
        "count_64": count64,
        "count_32": count32,
        "count_16": count16,
        "enumV": enumV.index,
        "boolV": boolV,
        "bytes": bytes,
        "string": string
      };

  int count64;
  int count32;
  int count16;
  MyEnum enumV;
  bool boolV;
  List<int> bytes;
  String string;
}

enum MyEnum { a, b, c, d }
