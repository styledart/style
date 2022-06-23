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

abstract class TypedDataKey<T> extends StyleKey<List<T>> {
  const TypedDataKey(this.itemLength, int key, {this.fixedCount}) : super(key);

  final int itemLength;

  final int? fixedCount;

  @override
  int? get fixedLength => fixedCount != null ? fixedCount! * itemLength : null;

  List<T> readItems(ByteDataReader byteData);

  T readItem(ByteDataReader data);

  @override
  List<T> read(ByteDataReader byteData, bool withTag) {
    return readItems(byteData);

    var listMeta = readMeta(byteData);
    var list = <T>[];

    while (list.length < listMeta.count) {
      list.add(readItem(byteData));
    }
    return list;
  }

  @override
  TypedDataMeta readMeta(ByteDataReader data) {
    if (fixedCount != null) {
      return TypedDataMeta(fixedCount!);
    } else {
      return TypedDataMeta(data.getUint16());
    }
  }
}

// create float32list key
class Float32ListKey extends TypedDataKey<double> {
  const Float32ListKey(int key, [int? fixedCount])
      : super(k32BitLength, key, fixedCount: fixedCount);

  @override
  List<double> readItems(ByteDataReader byteData) {
    var listMeta = readMeta(byteData);
    var list = <double>[];

    while (list.length < listMeta.count) {
      list.add(byteData.getFloat32());
    }
    return list;
  }

  @override
  double readItem(ByteDataReader data) {
    return data.getFloat32();
  }

  @override
  int get type => 23;
}

// create float64list key
class Float64ListKey extends TypedDataKey<double> {
  const Float64ListKey(int key, [int? fixedCount])
      : super(k64BitLength, key, fixedCount: fixedCount);

  @override
  List<double> readItems(ByteDataReader byteData) {
    var listMeta = readMeta(byteData);
    var list = <double>[];

    while (list.length < listMeta.count) {
      list.add(byteData.getFloat64());
    }
    return list;
  }

  @override
  double readItem(ByteDataReader data) {
    return data.getFloat64();
  }

  @override
  int get type => 24;
}

class Uint8ListKey extends StyleKey<Uint8List> {
  const Uint8ListKey(int key, [this.fixedCount]) : super(key);

  @override
  int get type => 10;

  final int? fixedCount;

  @override
  int? get fixedLength => fixedCount;

  @override
  Uint8List read(ByteDataReader byteData, bool withTag) {
    var listMeta = readMeta(byteData);

    return byteData.getBytes(listMeta.count);
  }

  @override
  TypedDataMeta readMeta(ByteDataReader data) {
    if (fixedCount != null) {
      return TypedDataMeta(fixedCount!);
    } else {
      return TypedDataMeta(data.getUint16());
    }
  }
}

class Uint8ListKeyWithTyped extends TypedDataKey<int> {
  const Uint8ListKeyWithTyped(int key, [int? fixedCount])
      : super(kByteLength, key, fixedCount: fixedCount);

  @override
  List<int> readItems(ByteDataReader byteData) {
    var listMeta = readMeta(byteData);
    var list = <int>[];

    while (list.length < listMeta.count) {
      list.add(byteData.getUint8());
    }
    return list;
  }

  @override
  int get type => 9;

  @override
  int readItem(ByteDataReader data) {
    return data.getUint8();
  }
}

class Int8ListKey extends TypedDataKey<int> {
  const Int8ListKey(int key, [int? fixedCount])
      : super(kByteLength, key, fixedCount: fixedCount);

  @override
  List<int> readItems(ByteDataReader byteData) {
    var listMeta = readMeta(byteData);
    var list = <int>[];

    while (list.length < listMeta.count) {
      list.add(byteData.getInt8());
    }
    return list;
  }

  @override
  int get type => 11;

  @override
  int readItem(ByteDataReader data) {
    return data.getInt8();
  }
}

class Uint16ListKey extends TypedDataKey<int> {
  const Uint16ListKey(int key, [int? fixedCount])
      : super(k16BitLength, key, fixedCount: fixedCount);

  @override
  List<int> readItems(ByteDataReader byteData) {
    var listMeta = readMeta(byteData);
    var list = <int>[];

    while (list.length < listMeta.count) {
      list.add(byteData.getUint16());
    }
    return list;
  }

  @override
  int get type => 12;

  @override
  int readItem(ByteDataReader data) {
    return data.getUint16();
  }
}

class Int16ListKey extends TypedDataKey<int> {
  const Int16ListKey(int key, [int? fixedCount])
      : super(k16BitLength, key, fixedCount: fixedCount);

  @override
  List<int> readItems(ByteDataReader byteData) {
    var listMeta = readMeta(byteData);
    var list = <int>[];

    while (list.length < listMeta.count) {
      list.add(byteData.getInt16());
    }
    return list;
  }

  @override
  int get type => 13;

  @override
  int readItem(ByteDataReader data) {
    return data.getInt16();
  }
}

class Int32ListKey extends TypedDataKey<int> {
  const Int32ListKey(int key, [int? fixedCount])
      : super(k32BitLength, key, fixedCount: fixedCount);

  @override
  List<int> readItems(ByteDataReader byteData) {
    var listMeta = readMeta(byteData);
    var list = <int>[];

    while (list.length < listMeta.count) {
      list.add(byteData.getInt32());
    }
    return list;
  }

  @override
  int get type => 15;

  @override
  int readItem(ByteDataReader data) {
    return data.getInt32();
  }
}

class Uint32ListKey extends TypedDataKey<int> {
  const Uint32ListKey(int key, [int? fixedCount])
      : super(k32BitLength, key, fixedCount: fixedCount);

  @override
  List<int> readItems(ByteDataReader byteData) {
    var listMeta = readMeta(byteData);
    var list = <int>[];

    while (list.length < listMeta.count) {
      list.add(byteData.getUint32());
    }
    return list;
  }

  @override
  int get type => 14;

  @override
  int readItem(ByteDataReader data) {
    return data.getUint32();
  }
}

class Int64ListKey extends TypedDataKey<int> {
  const Int64ListKey(int key, [int? fixedCount])
      : super(k64BitLength, key, fixedCount: fixedCount);

  @override
  List<int> readItems(ByteDataReader byteData) {
    var listMeta = readMeta(byteData);
    var list = <int>[];

    while (list.length < listMeta.count) {
      list.add(byteData.getInt64());
    }
    return list;
  }

  @override
  int get type => 17;

  @override
  int readItem(ByteDataReader data) {
    return data.getInt64();
  }
}

class Uint64ListKey extends TypedDataKey<int> {
  const Uint64ListKey(int key, [int? fixedCount])
      : super(k64BitLength, key, fixedCount: fixedCount);

  @override
  List<int> readItems(ByteDataReader byteData) {
    var listMeta = readMeta(byteData);
    var list = <int>[];

    while (list.length < listMeta.count) {
      list.add(byteData.getUint64());
    }
    return list;
  }

  @override
  int get type => 16;

  @override
  int readItem(ByteDataReader data) {
    return data.getInt64();
  }
}
