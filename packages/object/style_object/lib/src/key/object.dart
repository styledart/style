part of style_object;

class ObjectKey extends StyleKey<Map<Object, dynamic>> {
  const ObjectKey(super.key);

  @override
  int? get fixedLength => null;

  @override
  DataRead<Map<Object, dynamic>> read(ByteData byteData, int offset,
      covariant KeyCollection keyMapper, bool withTag) {
    var readCount = 0;
    var map = <Object, dynamic>{};
    var meta = readMeta(byteData, offset, keyMapper) as ObjectKeyMeta;

    offset = meta.offset;

    while (readCount < meta.entryCount) {
      var entryKey = keyMapper.readKey(byteData, offset);
      offset += kKeyLength;
      var dataRead = entryKey.root.read(byteData, offset, entryKey, withTag);
      offset = dataRead.offset;
      map[(entryKey.factoryKey)] =
          dataRead.data;

      readCount++;
    }
    return DataRead<Map<Object, dynamic>>(data: map, offset: offset);
  }

  @override
  KeyMetaRead readMeta(ByteData data, int offset, KeyFactory keyMapper) {
    return ObjectKeyMeta(data.getUint16(offset), offset + kKeyLength);
  }

  int writeKeyAndMeta(ByteData byteData, int offset, int count, bool withKey) {
    if (withKey) {
      byteData.setUint16(offset, key);
      offset += kKeyLength;
    }
    byteData.setUint16(offset, count);
    return offset + k16BitLength;
  }

  @override
  int get type => 17;
}
