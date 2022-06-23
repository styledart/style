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

class _Pair {
  _Pair(this.key, this.data);

  StyleKey key;
  StyleData data;
}

class ListData extends StyleData<List> {
  ListData(super.value);

  final List<_Pair> _data = [];

  @override
  StyleKey<List> createKey(int key) {
    return ListKey(key, []);
  }

  static int _getTypeForData(dynamic data) {
    var f = _types[data.runtimeType];

    if (f != null) {
      return f;
    } else if (data is Map<dynamic, StyleData>) {
      return 21;
    } else if (data is List<int>) {
      return 17;
    } else if (data is List) {
      return 22;
    } else if (data is StyleData) {
      return data.createKey(-255).type;
    } else {
      throw UnsupportedError("Type ${data.runtimeType} is not supported");
    }
  }

  static const Map<Type, int> _types = {
    bool: 1,
    int: 8,
    String: 20,
    double: 19,
    Uint8List: 10,
    Int8List: 11,
    Uint16List: 12,
    Int16List: 13,
    Uint32List: 14,
    Int32List: 15,
    Int64List: 17,
    List<int>: 17,
    List<double>: 24,
    Float32List: 23,
    Float64List: 24,
  };

  @override
  int getLength(covariant ListKey key) {
    // set _data with for in
    for (var i = 0; i < value.length; i++) {
      _data.add(_getPair(key, value[i]));
    }

    var l = kLengthLength;
    for (var d in _data) {
      var k = d.key;
      l += kByteLength + (k.fixedLength ?? d.data.getLength(k));
    }
    print('GET LIST LENGTH: $l');
    return l;
  }

  static _Pair _getPair(ListKey key, dynamic e) {
    var type = _getTypeForData(e);

    var k = key._keys[-type] ??= ListKey._createFakeKeyForType(type);
    return _Pair(k, StyleData.create(e));
  }

  @override
  void write(ByteDataWriter builder, covariant ListKey key, bool withKey) {
    key.writeKeyAndMeta(builder, value.length, withKey);
    print('LIST WRITE: ${_data}');
    for (var d in _data) {
      builder.setUint8(d.key.type);
      d.data.write(builder, d.key, false);
    }
  }
}
