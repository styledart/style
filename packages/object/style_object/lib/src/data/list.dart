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

class _Pair {
  _Pair(this.key, this.data);

  KeyFactory key;
  StyleData data;
}

class ListData extends StyleData<List> {
  ListData(super.value);

  List<_Pair>? _data;

  @override
  KeyFactory createKey(int key) {
    return KeyCollection.withRoot(ListKey(key), []);
  }

  static int _getTypeForData(dynamic data) {
    var f = _types[data.runtimeType];
    if (f != null) {
      return (f);
    } else if (data is Map<dynamic, StyleData>) {
      return (17);
    }
    /* else if (data is Map<int, StyleData>) {
      return 17;
    } else if (data is Map<String, StyleData>) {
      return 17;
    }*/
    else if (data is List<int>) {
      return (15);
    } else if (data is List) {
      return (18);
    } else if (data is StyleData) {
      return _getTypeForData(data.value);
    } else {
      throw UnsupportedError("Type ${data.runtimeType} is not supported");
    }
  }

  static const Map<Type, int> _types = {
    bool: 1,
    int: 8,
    String: 16,
    double: 22,
    Uint8List: 9,
    Int8List: 10,
    Uint16List: 11,
    Int16List: 12,
    Uint32List: 13,
    Int32List: 14,
    Int64List: 15,
  };

  @override
  int getLength(KeyFactory key) {
    _data ??= value
        .map((e) => _Pair(ListKey._createFakeKeyForType(_getTypeForData(e)),
            StyleData.create(e)))
        .toList();

    var l = 0;
    for (var d in _data!) {
      var k = d.key.root;
      l += kByteLength +
          (k.fixedLength ?? d.data.getLength(d.key is ObjectKey ? key : k));
    }
    return l + k16BitLength;
  }

  @override
  WriteMeta write(
    ByteData byteData,
    int offset,
    KeyFactory key,
    bool withKey,
  ) {
    var kOffset = offset;
    offset += withKey ? k32BitLength : k16BitLength;

    for (var d in _data!) {
      byteData.setUint8(offset, d.key.getKey(d.key.factoryKey, d.data).type);
      offset += kByteLength;
      var meta = d.data.write(byteData, offset, d.key, false);
      offset = meta.offset;
    }

    (key is ListKey ? key : (key as KeyCollection).root as ListKey)
        .writeKeyAndMeta(byteData, kOffset, value.length, 0, withKey);
    return WriteMeta(byteData, offset);
  }
}
