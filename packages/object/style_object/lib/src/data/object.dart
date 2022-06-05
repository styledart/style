part of style_object;

abstract class StyleObject extends StyleData<Map<Object, dynamic>> {
  StyleObject(super.value);

  Map<StyleKey, StyleData> get _data;

  void setData(KeyCollection keyMapper);

  @override
  WriteMeta write(
    ByteData byteData,
    int offset,
    covariant ObjectKey key,
    bool withKey,
  ) {
    var kOffset = offset;
    offset += withKey ? kObjectMetaLength : k16BitLength;
    for (var d in _data.entries) {
      var meta = d.value.write(byteData, offset, d.key, true);
      offset = meta.offset;
      byteData = meta.byteData;
    }
    key.writeKeyAndMeta(byteData, kOffset, _data.length, withKey);
    return WriteMeta(byteData, offset);
  }

  @override
  KeyFactory createKey(int key) {
    return KeyCollection.withRoot(ObjectKey(key), []);
  }

  @override
  int getLength(covariant KeyFactory key) {
    setData(key as KeyCollection);
    var len = kObjectMetaLength;

    for (var d in _data.entries) {
      len += d.key.fixedLength ?? (d.value).getLength(key.getChild(d.key.key));
    }
    return len + (kKeyLength * value.length);
  }
}

class StyleObjectAdvanced extends StyleObject {
  StyleObjectAdvanced(Map<StyleKey, StyleData> map) : super(map);

  @override
  Map<StyleKey, StyleData<dynamic>> get _data =>
      value as Map<StyleKey, StyleData>;

  @override
  void setData(KeyCollection keyMapper) {
    return;
  }
}

class StyleObjectWithData extends StyleObject {
  StyleObjectWithData(Map<int, StyleData> map) : super(map);

  Map<StyleKey, StyleData>? _map;

  @override
  Map<StyleKey, StyleData<dynamic>> get _data => _map!;

  @override
  void setData(KeyCollection keyMapper) {
    _map = <StyleKey, StyleData>{};
    (value as Map<int, StyleData>).forEach((key, value) {
      _map![keyMapper.getKey(key, value)] = value;
    });
    return;
  }
}

// class StyleObjectWithTags extends StyleObject {
//   StyleObjectWithTags(Map<String, dynamic> map) : super(map);
//
//   Map<StyleKey, StyleData>? _map;
//
//   @override
//   void setData(KeyCollection keyMapper) {
//     _map = {};
//     (value as Map<String, dynamic>).forEach((key, value) {
//       _map![keyMapper.getTagKey(key, value)] = StyleData.create(value);
//     });
//     return;
//   }
//
//   @override
//   Map<StyleKey, StyleData<dynamic>> get _data => _map!;
// }

class StyleObjectWithKeys extends StyleObject {
  StyleObjectWithKeys(Map<int, dynamic> map) : super(map);

  Map<StyleKey, StyleData>? _map;

  @override
  void setData(KeyCollection keyMapper) {
    _map = {};
    (value as Map<int, dynamic>).forEach((key, value) {
      _map![keyMapper.getKey(key, value)] = StyleData.create(value);
    });
    return;
  }

  @override
  Map<StyleKey, StyleData<dynamic>> get _data => _map!;
}
