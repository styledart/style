part of style_object;

class ObjectKeyMeta extends KeyMetaRead {
  ObjectKeyMeta(this.entryCount, super.offset);

  int entryCount;
}

class WriteMeta {
  WriteMeta(this.byteData, this.offset);

  ByteData byteData;
  int offset;
}
