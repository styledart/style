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

abstract class FixedLengthKey<T> extends StyleKey<T> {
  const FixedLengthKey(int key) : super(key);

  @override
  KeyMetaRead readMeta(ByteDataReader data) {
    throw ArgumentError("There is no meta for fixed length key");
  }

  @override
  T read(ByteDataReader byteData, bool withTag) {
    return readFixed(byteData);
  }

  T readFixed(ByteDataReader byteData);
}

class BoolKey extends FixedLengthKey<bool> {
  const BoolKey(super.key);

  @override
  bool readFixed(ByteDataReader byteData) {
    return byteData.getBool();
  }

  @override
  int? get fixedLength => kByteLength;

  @override
  int get type => 1;
}

class Int8Key extends FixedLengthKey<int> {
  const Int8Key(super.key);

  @override
  int readFixed(ByteDataReader byteData) {
    return byteData.getInt8();
  }

  @override
  int? get fixedLength => kByteLength;

  @override
  int get type => 3;
}

class Uint8Key extends FixedLengthKey<int> {
  const Uint8Key(super.key);

  @override
  int readFixed(ByteDataReader byteData) {
    return byteData.getUint8();
  }

  @override
  int? get fixedLength => kByteLength;

  @override
  int get type => 2;
}

class Int16Key extends FixedLengthKey<int> {
  const Int16Key(super.key);

  @override
  int readFixed(ByteDataReader byteData) {
    return byteData.getInt16();
  }

  @override
  int? get fixedLength => k16BitLength;

  @override
  int get type => 5;
}

class Uint16Key extends FixedLengthKey<int> {
  const Uint16Key(super.key);

  @override
  int readFixed(ByteDataReader byteData) {
    return byteData.getUint16();
  }

  @override
  int? get fixedLength => k16BitLength;

  @override
  int get type => 4;
}

class Int32Key extends FixedLengthKey<int> {
  const Int32Key(super.key);

  @override
  int readFixed(ByteDataReader byteData) {
    return byteData.getInt32();
  }

  @override
  int? get fixedLength => k32BitLength;

  @override
  int get type => 7;
}

class Uint32Key extends FixedLengthKey<int> {
  const Uint32Key(super.key);

  @override
  int readFixed(ByteDataReader byteData) {
    return byteData.getUint32();
  }

  @override
  int? get fixedLength => k32BitLength;

  @override
  int get type => 6;
}

class IntKey extends FixedLengthKey<int> {
  const IntKey(super.key);

  @override
  int readFixed(ByteDataReader byteData) {
    return byteData.getInt64();
  }

  @override
  int? get fixedLength => k64BitLength;

  @override
  int get type => 8;
}

class Int64Key extends FixedLengthKey<int> {
  const Int64Key(super.key);

  @override
  int readFixed(ByteDataReader byteData) {
    return byteData.getUint64();
  }

  @override
  int? get fixedLength => k64BitLength;

  @override
  int get type => 9;
}

class DoubleKey extends FixedLengthKey<double> {
  DoubleKey(super.key);

  @override
  double readFixed(ByteDataReader byteData) {
    return byteData.getFloat64();
  }

  @override
  int? get fixedLength => k64BitLength;

  @override
  int get type => 19;
}

class Float32Key extends FixedLengthKey<double> {
  Float32Key(super.key);

  @override
  double readFixed(ByteDataReader byteData) {
    return byteData.getFloat32();
  }

  @override
  int? get fixedLength => k32BitLength;

  @override
  int get type => 18;
}
