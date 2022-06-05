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

class StyleObjectCodec extends Codec<dynamic, ByteData> {
  StyleObjectCodec({KeyCollection? keyCollection})
      : keyMapper = keyCollection ?? KeyCollection();

  final KeyCollection keyMapper;

  @override
  StyleObjectDecoder get decoder => StyleObjectDecoder(keyMapper);

  @override
  StyleObjectEncoder get encoder => StyleObjectEncoder(keyMapper);
}

/// {
///   0 : {
///      ObjectKey(0),
///      1 : StringKey(3),
///      2 : {
///         ListKey(4),
///         5 : IntKey(5),
///         6 : BoolKey(6)
///      }
///   }
/// }
class KeyCollection with KeyFactory {
  @override
  final StyleKey root;

  KeyCollection.withRoot(this.root, [List<KeyFactory>? keyFactories]) {
    for (var fact in (keyFactories ?? [])) {
      _keys[fact.factoryKey] = fact;
    }
  }

  factory KeyCollection([List<KeyFactory>? keyFactories]) {
    return KeyCollection.withRoot(ObjectKey(0), keyFactories);
  }

  final Map<int, KeyFactory> _keys = {};

  KeyFactory getChild(int key) {
    return _keys[key]!;
  }

  @override
  StyleKey getKey(int key, StyleData data) {
    if (key == root.key) return root;
    return (_keys[key] ??= data.createKey(key)).getKey(key, data);
  }

  /// Get key by [tag]
  KeyFactory readKey(ByteData data, int offset) {
    var k = data.getUint16(offset);
    return getChild(k);
  }

  @override
  int get factoryKey => root.key;
}

class StyleObjectEncoder extends Converter<StyleObject, ByteData> {
  const StyleObjectEncoder(this.keyMapper);

  final KeyCollection keyMapper;

  ObjectKey get rootKey => keyMapper.root as ObjectKey;

  @override
  ByteData convert(StyleObject input) {
    var byteData = ByteData(input.getLength(keyMapper));
    input.write(byteData, 0, ObjectKey(0), true);
    return byteData;
  }
}

class StyleObjectDecoder extends Converter<ByteData, Map<int, Object?>> {
  const StyleObjectDecoder(this.keyMapper);

  final KeyCollection keyMapper;

  @override
  Map<int, Object?> convert(ByteData input) {
    var read = keyMapper.root.read(input, 2, keyMapper, false);
    return read.data.cast<int, Object>();
  }
}
