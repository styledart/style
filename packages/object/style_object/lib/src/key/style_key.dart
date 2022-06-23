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

mixin KeyFactory<T> {
  int get factoryKey;

  StyleKey get root;

  StyleKey getKey(int key, StyleData data);
}

abstract class StyleKey<T> with KeyFactory<T> {
  const StyleKey(this.key);

  final int key;

  @override
  int get factoryKey => key;

  int? get fixedLength;

  int get type;

  //final StyleKey? parent;

  @override
  StyleKey get root => this;

  @override
  StyleKey getKey(int key, StyleData data) => this;

  @override
  int get hashCode => key.hashCode;

  @override
  bool operator ==(dynamic other) {
    return other is StyleKey && other.key == key;
  }

  KeyMetaRead readMeta(ByteData data, int offset, KeyFactory keyMapper);

  DataRead<T> read(
      ByteData byteData, int offset, KeyFactory keyMapper, bool withTag);
}

