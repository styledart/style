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
part of style_object;

mixin KeyFactory<T> {
  int get factoryKey;

  StyleKey get root;

  StyleKey getKey(int key, StyleData data);
}

abstract class StyleKey<T> with KeyFactory<T> {
  const StyleKey(this.key);

  final int key;

  @override
  int get factoryKey => key;

  int? get fixedLength;

  int get type;

  //final StyleKey? parent;

  @override
  StyleKey get root => this;

  @override
  StyleKey getKey(int key, StyleData data) => this;

  @override
  int get hashCode => key.hashCode;

  @override
  bool operator ==(dynamic other) {
    return other is StyleKey && other.key == key;
  }

  KeyMetaRead readMeta(ByteData data, int offset, KeyFactory keyMapper);

  DataRead<T> read(
      ByteData byteData, int offset, KeyFactory keyMapper, bool withTag);
}

// static final typeLengths = <int, int>{
//   nullType: 0,
//   boolType: 1,
//   uint8Type: 1,
//   int8Type: 1,
//   uint16Type: 2,
//   int16Type: 2,
//   uint32Type: 4,
//   int32Type: 4,
//   int64Type: 8,
//   float32Type: 4,
//   float64Type: 8,
// };
//
// static const int nullType = 0x00;
// static const int boolType = 0x01;
//
// static const int uint8Type = 0x03;
// static const int int8Type = 0x04;
//
// static const int uint16Type = 0x05;
// static const int int16Type = 0x06;
//
// static const int uint32Type = 0x07;
// static const int int32Type = 0x08;
//
// static const int int64Type = 0x09;
//
// static const int float32Type = 0x0A;
// static const int float64Type = 0x0B;
//
// static const int dyListFixedLengthType = 0x0C;
// static const int dyListFixedType = 0x0D;
// static const int dyList = 0x0E;
// static const int fixedLengthList = 0x0F;
// static const int matrixFixedLen = 0x10;
//
// static const int objectType = 0x11;
// static const int objectList = 0x12;
//
// /// int64
// static const int dateType = 0x13;
//
// /// fixedLengthList
// static const int coordinateType = 0x14;
//
// /// fixedLengthList
// static const int idType = 0x15;
