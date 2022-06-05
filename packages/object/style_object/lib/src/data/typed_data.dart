/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE, Version 3 (the "License");
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

abstract class StyleTypedData<T extends num>
    extends StyleData<List<T>> {
  StyleTypedData(this.itemLength, super.value);

  int itemLength;

  // @override
  // TypedDataKey<T> createKey(int key,StyleKey? parent);

  @override
  int getLength(covariant TypedDataKey<T> key) =>
      (value.length * itemLength) + (key.fixedCount != null ? 0 : 2);

  void writeItem(ByteData data, int offset, T value);

  @override
  WriteMeta write(ByteData byteData, int offset,covariant  TypedDataKey<T> key, bool withKey) {
    offset = key.writeKeyAndMeta(byteData, offset, value.length, withKey);

    // var bt = typedData.buffer.asUint8List();
    // var e = offset + bt.length;
    // var b = byteData.buffer.asUint8List()..setRange(offset, e, bt);
    for (var v in value) {
      writeItem(byteData, offset, v);
      offset += itemLength;
    }

    return WriteMeta(byteData, offset);
  }

  TypedData get typedData;
}

class Uint8ListData extends StyleTypedData<int> {
  Uint8ListData(List<int> value) : super(kByteLength, value);

  @override
  TypedDataKey<int> createKey(int key) {
    return Uint8ListKey(key);
  }

  @override
  TypedData get typedData => Uint8List.fromList(value);

  @override
  void writeItem(ByteData data, int offset, int value) {
    data.setUint8(offset, value);
  }
}

class Int8ListData extends StyleTypedData<int> {
  Int8ListData(List<int> value) : super(kByteLength, value);

  @override
  TypedDataKey<int> createKey(int key) {
    return Uint8ListKey(key);
  }

  @override
  TypedData get typedData => Int8List.fromList(value);

  @override
  void writeItem(ByteData data, int offset, int value) {
    data.setInt8(offset, value);
  }

}

class Uint16ListData extends StyleTypedData<int> {
  Uint16ListData(List<int> value) : super(k16BitLength, value);

  @override
  TypedDataKey<int> createKey(int key) {
    return Uint16ListKey(key);
  }

  @override
  TypedData get typedData => Uint16List.fromList(value);


  @override
  void writeItem(ByteData data, int offset, int value) {
    data.setUint16(offset, value);
  }

}

class Int16ListData extends StyleTypedData<int> {
  Int16ListData(List<int> value) : super(k16BitLength, value);

  @override
  TypedDataKey<int> createKey(int key) {
    return Int16ListKey(key);
  }

  @override
  TypedData get typedData => Int16List.fromList(value);


  @override
  void writeItem(ByteData data, int offset, int value) {
    data.setInt16(offset, value);
  }

}

class Uint32ListData extends StyleTypedData<int> {
  Uint32ListData(List<int> value) : super(k32BitLength, value);

  @override
  TypedDataKey<int> createKey(int key) {
    return Uint32ListKey(key);
  }

  @override
  TypedData get typedData => Uint32List.fromList(value);

  @override
  void writeItem(ByteData data, int offset, int value) {
    data.setUint32(offset, value);
  }
}

class Int32ListData extends StyleTypedData<int> {
  Int32ListData(List<int> value) : super(k32BitLength, value);

  @override
  TypedDataKey<int> createKey(int key) {
    return Int32ListKey(key);
  }

  @override
  TypedData get typedData => Int32List.fromList(value);


  @override
  void writeItem(ByteData data, int offset, int value) {
    data.setInt32(offset, value);
  }

}

class Int64ListData extends StyleTypedData<int> {
  Int64ListData(List<int> value) : super(k64BitLength, value);

  @override
  TypedDataKey<int> createKey(int key) {
    return Int64ListKey(key);
  }

  @override
  TypedData get typedData => Int64List.fromList(value);

  @override
  void writeItem(ByteData data, int offset, int value) {
    data.setInt64(offset, value);
  }

}
