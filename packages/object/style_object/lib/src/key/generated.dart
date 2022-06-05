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

class StringKey extends StyleKey<String> {
  const StringKey(int key, [this.fixedCount]) : super(key);

  final int? fixedCount;

  @override
  DataRead<String> read(
      ByteData byteData, int offset, KeyFactory keyMapper, bool withTag) {
    var listMeta = readMeta(byteData, offset, keyMapper);
    offset = listMeta.offset;
    return DataRead(
        data: utf8.decode(byteData.buffer.asUint8List(offset, listMeta.count)),
        offset: offset + listMeta.count);
  }

  @override
  TypedDataMeta readMeta(ByteData data, int offset, KeyFactory keyMapper) {
    if (fixedCount != null) {
      return TypedDataMeta(fixedCount!, offset);
    } else {
      return TypedDataMeta(data.getUint16(offset), offset + k16BitLength);
    }
  }

  int writeKeyAndMeta(ByteData byteData, int offset, int count, bool withKey) {
    if (withKey) {
      byteData.setUint16(offset, key);
      offset += kKeyLength;
    }

    if (fixedCount == null) {
      byteData.setUint16(offset, count);
      offset += kKeyLength;
    }
    return offset;
  }

  @override
  int? get fixedLength => fixedCount;

  @override
  int get type => 16;

}
