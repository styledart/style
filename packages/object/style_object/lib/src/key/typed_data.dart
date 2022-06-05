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

abstract class TypedDataKey<T> extends StyleKey<List<T>> {
  const TypedDataKey(this.itemLength, int key, {this.fixedCount}) : super(key);

  final int itemLength;

  final int? fixedCount;

  @override
  int? get fixedLength => fixedCount != null ? fixedCount! * itemLength : null;

  List<T> readItems(ByteData byteData, int offset, int lengthInBytes);

  T readItem(ByteData data, int offset);

  @override
  DataRead<List<T>> read(
      ByteData byteData, int offset, KeyFactory keyMapper, bool withTag) {
    var listMeta = readMeta(byteData, offset, keyMapper);
    offset = listMeta.offset;
    var list = <T>[];

    while (list.length < listMeta.count) {
      list.add(readItem(byteData, offset));
      offset += itemLength;
    }
    return DataRead(data: list, offset: offset);
    // var lengthInBytes = (itemLength * listMeta.count);
    //
    // return DataRead(
    //     data: readItems(byteData, offset, lengthInBytes),
    //     offset: offset + lengthInBytes);
  }

  @override
  TypedDataMeta readMeta(ByteData data, int offset, KeyFactory keyMapper) {
    if (fixedCount != null) {
      return TypedDataMeta(fixedCount!, offset);
    } else {
      return TypedDataMeta(data.getUint16(offset), offset + k16BitLength);
    }
  }

  int writeKeyAndMeta(ByteData byteData, int offset, int count, bool withKey) {
    if (withKey) {
      byteData.setUint16(offset, key);
      offset += kKeyLength;
    }
    if (fixedCount == null) {
      byteData.setUint16(offset, count);
      offset += kKeyLength;
    }
    return offset;
  }
}

class Uint8ListKey extends TypedDataKey<int> {
  const Uint8ListKey(int key, [int? fixedCount])
      : super(kByteLength, key, fixedCount: fixedCount);

  @override
  List<int> readItems(ByteData byteData, int offset, int lengthInBytes) {
    return byteData.buffer.asUint8List(offset, lengthInBytes);
  }

  @override
  int get type => 9;

  @override
  int readItem(ByteData data, int offset) {
    return data.getUint8(offset);
  }
}

class Int8ListKey extends TypedDataKey<int> {
  const Int8ListKey(int key, [int? fixedCount])
      : super(kByteLength, key, fixedCount: fixedCount);

  @override
  List<int> readItems(ByteData byteData, int offset, int lengthInBytes) {
    return byteData.buffer.asInt8List(offset, lengthInBytes);
  }

  @override
  int get type => 10;

  @override
  int readItem(ByteData data, int offset) {
    return data.getInt8(offset);
  }
}

class Uint16ListKey extends TypedDataKey<int> {
  const Uint16ListKey(int key, [int? fixedCount])
      : super(k16BitLength, key, fixedCount: fixedCount);

  @override
  List<int> readItems(ByteData byteData, int offset, int lengthInBytes) {
    return byteData.buffer.asUint16List(offset, lengthInBytes);
  }

  @override
  int get type => 11;

  @override
  int readItem(ByteData data, int offset) {
    return data.getUint16(offset);
  }
}

class Int16ListKey extends TypedDataKey<int> {
  const Int16ListKey(int key, [int? fixedCount])
      : super(k16BitLength, key, fixedCount: fixedCount);

  @override
  List<int> readItems(ByteData byteData, int offset, int lengthInBytes) {
    return byteData.buffer.asInt16List(offset, lengthInBytes);
  }

  @override
  int get type => 12;

  @override
  int readItem(ByteData data, int offset) {
    return data.getInt16(offset);
  }
}

class Int32ListKey extends TypedDataKey<int> {
  const Int32ListKey(int key, [int? fixedCount])
      : super(k32BitLength, key, fixedCount: fixedCount);

  @override
  List<int> readItems(ByteData byteData, int offset, int lengthInBytes) {
    return byteData.buffer.asInt32List(offset, lengthInBytes);
  }

  @override
  int get type => 18;

  @override
  int readItem(ByteData data, int offset) {
    return data.getInt32(offset);
  }
}

class Uint32ListKey extends TypedDataKey<int> {
  const Uint32ListKey(int key, [int? fixedCount])
      : super(k32BitLength, key, fixedCount: fixedCount);

  @override
  List<int> readItems(ByteData byteData, int offset, int lengthInBytes) {
    return byteData.buffer.asUint32List(offset, lengthInBytes);
  }

  @override
  int get type => 13;

  @override
  int readItem(ByteData data, int offset) {
    return data.getUint32(offset);
  }
}

class Int64ListKey extends TypedDataKey<int> {
  const Int64ListKey(int key, [int? fixedCount])
      : super(k64BitLength, key, fixedCount: fixedCount);

  @override
  List<int> readItems(ByteData byteData, int offset, int lengthInBytes) =>
      byteData.buffer.asInt64List(offset, lengthInBytes);

  @override
  int get type => 15;

  @override
  int readItem(ByteData data, int offset) {
    return data.getInt64(offset);
  }
}
