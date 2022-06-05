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

class ListKey extends StyleKey<List> {
  ListKey(super.key, /*[this.fixedType]*/);

  @override
  int? get fixedLength => null;

  //int? fixedType;

  @override
  DataRead<List> read(
      ByteData byteData, int offset, KeyFactory keyMapper, bool withTag) {
    var listMeta = readMeta(byteData, offset, keyMapper);
    offset = listMeta.offset;
    var list = [];
    while (list.length < listMeta.count) {
      var key = _createFakeKeyForType(byteData.getUint8(offset), null);
      offset += kByteLength;
      var o = key.read(
          byteData, offset, key is ObjectKey ? keyMapper : key, withTag);
      list.add(o.data);
      offset = o.offset;
    }
    return DataRead(data: list, offset: offset);
  }

  @override
  ListMeta readMeta(ByteData data, int offset, KeyFactory keyMapper) {
    return ListMeta(data.getUint16(offset), offset + k16BitLength);
  }

  int writeKeyAndMeta(
      ByteData byteData, int offset, int count, int type, bool withKey) {
    if (withKey) {
      byteData.setUint16(offset, key);
      offset += kKeyLength;
    }
    byteData.setUint16(offset, count);
    return offset + k16BitLength;
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
    return _typeKeys[type]!.call(fixedCount);
  }

  static final Map<int, StyleKey Function(int? fixed)> _typeKeys = {
    1: (f) => BoolKey(-1),
    2: (f) => Uint8Key(-1),
    3: (f) => Int8Key(-1),
    4: (f) => Uint16Key(-1),
    5: (f) => Int16Key(-1),
    6: (f) => Uint32Key(-1),
    7: (f) => Int32Key(-1),
    8: (f) => IntKey(-1),

    21: (f) => Float32Key(-1),
    22: (f) => DoubleKey(-1),

    // typed data
    9: (f) => Uint8ListKey(-1, f),
    10: (f) => Int8ListKey(-1, f),
    11: (f) => Uint16ListKey(-1, f),
    12: (f) => Int16ListKey(-1, f),
    13: (f) => Uint32ListKey(-1, f),
    14: (f) => Int32ListKey(-1, f),
    15: (f) => Int64ListKey(-1, f),

    // generated
    16: (f) => StringKey(-1, f),

    // structures
    17: (f) => ObjectKey(-1),
    18: (f) => ListKey(-1),
  };

  @override
  int get type => 18;
}
