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

abstract class StyleTypedData<T extends num> extends StyleData<List<T>> {
  StyleTypedData(this.itemLength, super.value);

  int itemLength;

  @override
  int getLength(covariant TypedDataKey<T> key) =>
      (value.length * itemLength) +
      (key.fixedCount == null ? kLengthLength : 0);

  void writeItem(ByteDataWriter data, T value);

  @override
  void write(
      ByteDataWriter builder, covariant TypedDataKey<T> key, bool withKey) {
    if (withKey) {
      builder.setUint16(key.key);
    }

    if (key.fixedCount == null) {
      builder.setUint16(value.length);
    }
    for (var v in value) {
      writeItem(builder, v);
    }
  }

  TypedData get typedData;
}

class Uint8ListDataWithTyped extends StyleTypedData<int> {
  Uint8ListDataWithTyped(List<int> value) : super(kByteLength, value);

  @override
  StyleKey createKey(int key) {
    return Uint8ListKeyWithTyped(key);
  }

  @override
  TypedData get typedData => throw UnimplementedError();

  @override
  void writeItem(ByteDataWriter data, int value) {
    data.setUint8(value);
  }
}

class Uint8ListData extends StyleData<Uint8List> {
  Uint8ListData(Uint8List value) : super(value);

  @override
  Uint8ListKey createKey(int key) {
    return Uint8ListKey(key);
  }

  @override
  int getLength(covariant Uint8ListKey key) {
    return key.fixedCount != null
        ? key.fixedCount!
        : (kLengthLength + value.length);
  }

  @override
  void write(ByteDataWriter builder, covariant Uint8ListKey key, bool withKey) {
    if (withKey) {
      builder.setUint16(key.key);
    }

    if (key.fixedCount == null) {
      builder.setUint16(value.length);
    }

    builder.setBytes(value);
  }
}

class Int8ListData extends StyleTypedData<int> {
  Int8ListData(List<int> value) : super(kByteLength, value);

  @override
  TypedDataKey<int> createKey(int key) {
    return Int8ListKey(key);
  }

  @override
  TypedData get typedData => Int8List.fromList(value);

  @override
  void writeItem(ByteDataWriter data, int value) {
    data.setInt8(value);
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
  void writeItem(ByteDataWriter data, int value) {
    data.setUint16(value);
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
  void writeItem(ByteDataWriter data, int value) {
    data.setInt16(value);
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
  void writeItem(ByteDataWriter data, int value) {
    data.setUint32(value);
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
  void writeItem(ByteDataWriter data, int value) {
    data.setInt32(value);
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
  void writeItem(ByteDataWriter data, int value) {
    data.setInt64(value);
  }
}

class Uint64ListData extends StyleTypedData<int> {
  Uint64ListData(List<int> value) : super(k64BitLength, value);

  @override
  TypedDataKey<int> createKey(int key) {
    return Uint64ListKey(key);
  }

  @override
  TypedData get typedData => Uint64List.fromList(value);

  @override
  void writeItem(ByteDataWriter data, int value) {
    data.setUint64(value);
  }
}
