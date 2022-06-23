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

abstract class StyleObject extends StyleData<Map<Object, dynamic>> {
  StyleObject(super.value);

  final Map<StyleKey, StyleData> _data = {};

  void setData(ObjectKey keyMapper);

  @override
  void write(ByteDataWriter builder, covariant ObjectKey key, bool withKey) {
    if (withKey) {
      builder.setUint16(key.key);
    }

    if (key.fixedLength == null) {
      builder.setUint16(_data.length);
    }

    for (var d in _data.entries) {
      d.value.write(builder, d.key, true);
    }
  }

  @override
  ObjectKey createKey(int key) {
    return ObjectKey(key);
  }

  @override
  int getLength(covariant ObjectKey key) {
    setData(key);

    var len = kLengthLength;

    for (var d in _data.entries) {
      len += kKeyLength + (d.key.fixedLength ?? d.value.getLength(d.key));
    }
    return len;
  }
}

class StyleObjectAdvanced extends StyleObject {
  StyleObjectAdvanced(Map<StyleKey, StyleData> map) : super(map);

  @override
  Map<StyleKey, StyleData<dynamic>> get _data =>
      value as Map<StyleKey, StyleData>;

  @override
  void setData(ObjectKey keyMapper) {
    return;
  }
}

class StyleObjectWithData extends StyleObject {
  StyleObjectWithData(Map<int, StyleData> map) : super(map);

  @override
  void setData(ObjectKey keyMapper) {
    (value as Map<int, StyleData>).forEach((key, value) {
      _data[keyMapper.getKey(key, value)] = value;
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

  @override
  void setData(ObjectKey keyMapper) {
    for (var kv in (value as Map<int, dynamic>).entries) {
      _data[keyMapper.getKey(kv.key, kv.value)] = StyleData.create(kv.value);
    }
    return;
  }
}
