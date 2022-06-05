part of style_object;

class ListMeta extends KeyMetaRead {
  ListMeta(this.count, super.offset);

/*  int type;*/
  int count;
}

class TypedDataMeta extends KeyMetaRead {
  TypedDataMeta(this.count, super.offset);

  int count;
}
