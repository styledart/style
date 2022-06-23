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

class StringData extends StyleData<String> {
  StringData(String data)
      : _utf8 = utf8.encode(data) as Uint8List,
        super(data);

  final Uint8List _utf8;

  @override
  StringKey createKey(int key) {
    return StringKey(key);
  }

  @override
  int getLength(covariant StringKey key) =>
      (_utf8.length) + (key.fixedCount == null ? kLengthLength : 0);

  @override
  void write(ByteDataWriter builder, covariant StringKey key, bool withKey) {
    key.writeKeyAndMeta(builder, _utf8.length, withKey);
    builder.setBytes(_utf8);
  }
}
