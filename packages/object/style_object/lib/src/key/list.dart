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

part of style_object;

class ListKey extends StyleKey<List> with KeyCollection {
  ListKey(super.key, List<StyleKey> keys);

  @override
  int? get fixedLength => null;

  @override
  List read(ByteDataReader byteData, bool withTag) {
    var listMeta = readMeta(byteData);
    var list = [];
    while (list.length < listMeta.count) {
      var k = byteData.getUint8();
      var key = _keys[-k] ??= _createFakeKeyForType(k, null);
      var o = key.read(byteData, false);
      list.add(o);
    }
    return list;
  }

  @override
  ListMeta readMeta(ByteDataReader data) {
    return ListMeta(data.getUint16());
  }

  void writeKeyAndMeta(ByteDataWriter builder, int count, bool withKey) {
    if (withKey) {
      builder.setUint16(key);
    }

    builder.setUint16(count);
  }

  // static DataRead<List<dynamic>> dynamicReader(
  //     ByteData data, int offset, ObjectKeyMapper keyMapper, int count, bool withTag) {
  //   var list = [];
  //   while (list.length < count) {
  //     var key = _createFakeKeyForType(data.getUint8(offset), null);
  //     offset += kByteLength;
  //     var o = key.read(data, offset, keyMapper,withTag);
  //     list.add(o.data);
  //     offset = o.offset;
  //   }
  //   return DataRead(data: list, offset: offset);
  // }

  // static DataRead<List<T>> typedReader<T>(ByteData data, int offset,
  //     ObjectKeyMapper keyMapper, int count, int type) {
  //   var key = _createFakeKeyForType(type);
  //   var list = <T>[];
  //   while (list.length < count) {
  //     var o = key.read(data, offset, keyMapper);
  //     list.add(o.data as T);
  //     offset = o.offset;
  //   }
  //   return DataRead(data: list, offset: offset);
  // }

  static StyleKey _createFakeKeyForType(int type, [int? fixedCount]) {
    print('TYPE: $type');
    return _typeKeys[type]!.call(fixedCount);
  }

  static final Map<int, StyleKey Function(int? fixed)> _typeKeys = {
    1: (f) => BoolKey(-1),
    2: (f) => Uint8Key(-2),
    3: (f) => Int8Key(-3),
    4: (f) => Uint16Key(-4),
    5: (f) => Int16Key(-5),
    6: (f) => Uint32Key(-6),
    7: (f) => Int32Key(-7),
    8: (f) => IntKey(-8),
    9: (f) => Int64Key(-9),

    // typed data
    10: (f) => Uint8ListKey(-10, f),
    11: (f) => Int8ListKey(-11, f),
    12: (f) => Uint16ListKey(-12, f),
    13: (f) => Int16ListKey(-13, f),
    14: (f) => Uint32ListKey(-14, f),
    15: (f) => Int32ListKey(-15, f),
    16: (f) => Uint64ListKey(-16, f),
    17: (f) => Int64ListKey(-17, f),

    23: (f) => Float32ListKey(-23, f),
    24: (f) => Float64ListKey(-24, f),

    18: (f) => Float32Key(-18),
    19: (f) => DoubleKey(-19),

    // generated
    20: (f) => StringKey(-20, f),

    // structures
    21: (f) => ObjectKey(-21),
    22: (f) => ListKey(-22, []),
  };

  @override
  int get type => 22;
}
