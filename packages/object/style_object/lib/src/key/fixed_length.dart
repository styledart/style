part of style_object;

abstract class FixedLengthKey<T> extends StyleKey<T> {
  const FixedLengthKey(int key) : super(key);

  @override
  KeyMetaRead readMeta(ByteData data, int offset, KeyFactory keyMapper) {
    throw ArgumentError("There is no meta for fixed length key");
  }

  @override
  DataRead<T> read(
      ByteData byteData, int offset, KeyFactory keyMapper, bool withTag) {
    return readFixed(byteData, offset, keyMapper);
  }

  DataRead<T> readFixed(
      ByteData byteData, int offset, KeyFactory keyMapper);

  int writeKeyAndMeta(ByteData byteData, int offset, bool withKey) {
    if (withKey) {
      byteData.setUint16(offset, key);
      return offset + kKeyLength;
    }
    return offset;
  }
}

class BoolKey extends FixedLengthKey<bool> {
  const BoolKey(super.key);

  @override
  DataRead<bool> readFixed(
      ByteData byteData, int offset, KeyFactory keyMapper) {
    return DataRead(data: byteData.getInt8(offset) == 1, offset: offset + 1);
  }

  @override
  int? get fixedLength => 1;

  @override
  int get type => 1;
}

class Int8Key extends FixedLengthKey<int> {
  const Int8Key(super.key);

  @override
  DataRead<int> readFixed(
      ByteData byteData, int offset, KeyFactory keyMapper) {
    return DataRead(data: byteData.getInt8(offset), offset: offset + 1);
  }

  @override
  int? get fixedLength => 1;

  @override
  int get type => 3;
}

class Uint8Key extends FixedLengthKey<int> {
  const Uint8Key(super.key);

  @override
  DataRead<int> readFixed(
      ByteData byteData, int offset, KeyFactory keyMapper) {
    return DataRead(data: byteData.getUint8(offset), offset: offset + 1);
  }

  @override
  int? get fixedLength => 1;

  @override
  int get type => 2;
}

class Int16Key extends FixedLengthKey<int> {
  const Int16Key(super.key);

  @override
  DataRead<int> readFixed(
      ByteData byteData, int offset, KeyFactory keyMapper) {
    return DataRead(
        data: byteData.getUint8(offset), offset: offset + k16BitLength);
  }

  @override
  int? get fixedLength => k16BitLength;

  @override
  int get type => 5;
}

class Uint16Key extends FixedLengthKey<int> {
  const Uint16Key(super.key);

  @override
  DataRead<int> readFixed(
      ByteData byteData, int offset, KeyFactory keyMapper) {
    return DataRead(
        data: byteData.getUint8(offset), offset: offset + k16BitLength);
  }

  @override
  int? get fixedLength => k16BitLength;

  @override
  int get type => 4;
}

class Int32Key extends FixedLengthKey<int> {
  const Int32Key(super.key);

  @override
  DataRead<int> readFixed(ByteData byteData, int offset, KeyFactory keyMapper) {
    return DataRead(
        data: byteData.getInt32(offset), offset: offset + k32BitLength);
  }

  @override
  int? get fixedLength => k32BitLength;

  @override
  int get type => 7;
}

class Uint32Key extends FixedLengthKey<int> {
  const Uint32Key(super.key);

  @override
  DataRead<int> readFixed(ByteData byteData, int offset, KeyFactory keyMapper) {
    return DataRead(
        data: byteData.getInt32(offset), offset: offset + k32BitLength);
  }

  @override
  int? get fixedLength => k32BitLength;

  @override
  int get type => 6;
}

class IntKey extends FixedLengthKey<int> {
  const IntKey(super.key);

  @override
  DataRead<int> readFixed(ByteData byteData, int offset, KeyFactory keyMapper) {
    return DataRead(
        data: byteData.getInt64(offset), offset: offset + k64BitLength);
  }

  @override
  int? get fixedLength => k64BitLength;

  @override
  int get type => 8;
}

class DoubleKey extends FixedLengthKey<double> {
  DoubleKey(super.key);

  @override
  DataRead<double> readFixed(
      ByteData byteData, int offset, KeyFactory keyMapper) {
    return DataRead(
        data: byteData.getFloat64(offset), offset: offset + k64BitLength);
  }

  @override
  int? get fixedLength => k64BitLength;

  @override
  int get type => 22;
}

class Float32Key extends FixedLengthKey<double> {
  Float32Key(super.key);

  @override
  DataRead<double> readFixed(
      ByteData byteData, int offset, KeyFactory keyMapper) {
    return DataRead(
        data: byteData.getFloat32(offset), offset: offset + k32BitLength);
  }

  @override
  int? get fixedLength => k32BitLength;

  @override
  int get type => 21;
}
