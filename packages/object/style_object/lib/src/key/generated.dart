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
  String read(ByteDataReader byteData, bool withTag) {
    var listMeta = readMeta(byteData);
    return byteData.getString(listMeta.count);
  }

  @override
  TypedDataMeta readMeta(ByteDataReader data) {
    if (fixedCount != null) {
      return TypedDataMeta(fixedCount!);
    } else {
      return TypedDataMeta(data.getUint16());
    }
  }

  void writeKeyAndMeta(ByteDataWriter builder, int count, bool withKey) {
    if (withKey) {
      builder.setUint16(key);
    }

    if (fixedCount == null) {
      builder.setUint16(count);
    }
  }

  @override
  int? get fixedLength => fixedCount;

  @override
  int get type => 20;
}
