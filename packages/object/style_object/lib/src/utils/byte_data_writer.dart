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

class ByteDataWriter {
  ByteDataWriter(this.byteData);

  final ByteData byteData;
  int offset = 0;

  void setBytes(Uint8List data) {
    var e = offset + data.length;
    byteData.buffer.asUint8List().setRange(offset, e, data);
    offset = e;
  }

  void setUint8(int value) {
    byteData.setUint8(offset, value);
    offset += kByteLength;
  }

  void setUint16(int value) {
    byteData.setUint16(offset, value);
    offset += k16BitLength;
  }

  void setUint32(int value) {
    byteData.setUint32(offset, value);
    offset += k32BitLength;
  }

  void setInt8(int value) {
    byteData.setInt8(offset, value);
    offset += kByteLength;
  }

  void setInt16(int value) {
    byteData.setInt16(offset, value);
    offset += k16BitLength;
  }

  void setInt32(int value) {
    byteData.setInt32(offset, value);
    offset += k32BitLength;
  }

  void setInt64(int value) {
    byteData.setInt64(offset, value);
    offset += k64BitLength;
  }

  void setUint64(int value) {
    byteData.setUint64(offset, value);
    offset += k64BitLength;
  }

  void setFloat32(double value) {
    byteData.setFloat32(offset, value);
    offset += k32BitLength;
  }

  void setFloat64(double value) {
    byteData.setFloat64(offset, value);
    offset += k64BitLength;
  }

  void setBool(bool value) {
    byteData.setUint8(offset, value ? 1 : 0);
    offset++;
  }
}
