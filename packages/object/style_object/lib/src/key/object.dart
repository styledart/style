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

class ObjectKey extends StyleKey<Map<Object, dynamic>> {
  const ObjectKey(super.key);

  @override
  int? get fixedLength => null;

  @override
  DataRead<Map<Object, dynamic>> read(ByteData byteData, int offset,
      covariant KeyCollection keyMapper, bool withTag) {
    var readCount = 0;
    var map = <Object, dynamic>{};
    var meta = readMeta(byteData, offset, keyMapper) as ObjectKeyMeta;

    offset = meta.offset;

    while (readCount < meta.entryCount) {
      var entryKey = keyMapper.readKey(byteData, offset);
      offset += kKeyLength;
      var dataRead = entryKey.root.read(byteData, offset, entryKey, withTag);
      offset = dataRead.offset;
      map[(entryKey.factoryKey)] =
          dataRead.data;

      readCount++;
    }
    return DataRead<Map<Object, dynamic>>(data: map, offset: offset);
  }

  @override
  KeyMetaRead readMeta(ByteData data, int offset, KeyFactory keyMapper) {
    return ObjectKeyMeta(data.getUint16(offset), offset + kKeyLength);
  }

  int writeKeyAndMeta(ByteData byteData, int offset, int count, bool withKey) {
    if (withKey) {
      byteData.setUint16(offset, key);
      offset += kKeyLength;
    }
    byteData.setUint16(offset, count);
    return offset + k16BitLength;
  }

  @override
  int get type => 17;
}
