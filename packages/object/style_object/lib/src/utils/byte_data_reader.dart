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

class ByteDataReader {
  ByteDataReader(this.byteData);

  final ByteData byteData;
  int offset = 2;

  List<int> getUInt8List(int length) {
    var result = <int>[];
    for (var i = 0; i < length; i++) {
      result.add(byteData.getInt8(offset));
      offset += kByteLength;
    }
    return result;
  }

  List<int> getUint16List(int length) {
    var result = <int>[];
    for (var i = 0; i < length; i++) {
      result.add(byteData.getUint16(offset));
      offset += k16BitLength;
    }
    return result;
  }

  List<int> getUint32List(int length) {
    var result = <int>[];
    for (var i = 0; i < length; i++) {
      result.add(byteData.getUint32(offset));
      offset += k32BitLength;
    }
    return result;
  }

  List<int> getInt8List(int length) {
    var result = <int>[];
    for (var i = 0; i < length; i++) {
      result.add(byteData.getInt8(offset));
      offset += kByteLength;
    }
    return result;
  }

  List<int> getInt16List(int length) {
    var result = <int>[];
    for (var i = 0; i < length; i++) {
      result.add(byteData.getInt16(offset));
      offset += k16BitLength;
    }
    return result;
  }

  List<int> getInt32List(int length) {
    var result = <int>[];
    for (var i = 0; i < length; i++) {
      result.add(byteData.getInt32(offset));
      offset += k32BitLength;
    }
    return result;
  }

  List<int> getInt64List(int length) {
    var result = <int>[];
    for (var i = 0; i < length; i++) {
      result.add(byteData.getInt64(offset));
      offset += k64BitLength;
    }
    return result;
  }

  List<int> getUint64List(int length) {
    var result = <int>[];
    for (var i = 0; i < length; i++) {
      result.add(byteData.getUint64(offset));
      offset += k64BitLength;
    }
    return result;
  }

  int getUint8() {
    var value = byteData.getUint8(offset);
    offset += kByteLength;
    return value;
  }

  int getUint16() {
    var value = byteData.getUint16(offset);
    offset += k16BitLength;
    return value;
  }

  int getUint32() {
    var value = byteData.getUint32(offset);
    offset += k32BitLength;
    return value;
  }

  int getInt8() {
    var value = byteData.getInt8(offset);
    offset += kByteLength;
    return value;
  }

  int getInt16() {
    var value = byteData.getInt16(offset);
    offset += k16BitLength;
    return value;
  }

  int getInt32() {
    var value = byteData.getInt32(offset);
    offset += k32BitLength;
    return value;
  }

  int getInt64() {
    var value = byteData.getInt64(offset);
    offset += k64BitLength;
    return value;
  }

  int getUint64() {
    var value = byteData.getUint64(offset);
    offset += k64BitLength;
    return value;
  }

  double getFloat32() {
    var value = byteData.getFloat32(offset);
    offset += k32BitLength;
    return value;
  }

  double getFloat64() {
    var value = byteData.getFloat64(offset);
    offset += k64BitLength;
    return value;
  }

  bool getBool() {
    var value = byteData.getUint8(offset) == 1;
    offset++;
    return value;
  }

  Uint8List getBytes(int length) {
    var value = byteData.buffer.asUint8List(offset, length);
    offset += length;
    return value;
  }

  String getString(int length) {
    var value = utf8.decode(byteData.buffer.asUint8List(offset, length));
    offset += length;
    return value;
  }
}
