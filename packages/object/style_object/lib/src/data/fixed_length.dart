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

class Int8Data extends StyleData<int> {
  Int8Data(super.value);

  @override
  StyleKey createKey(int key) {
    return Int8Key(key);
  }

  @override
  WriteMeta write(
    ByteData byteData,
    int offset,
      covariant Int8Key key,
    bool withKey,
  ) {
    offset = key.writeKeyAndMeta(byteData, offset, withKey);
    byteData.setInt8(offset, value);
    return WriteMeta(byteData, offset + kByteLength);
  }

  @override
  int getLength(covariant Int8Key key, ) => kByteLength;
}

class Uint8Data extends StyleData<int> {
  Uint8Data(super.value);

  @override
  StyleKey createKey(int key) {
    return Int8Key(key);
  }

  @override
  WriteMeta write(
    ByteData byteData,
    int offset,
      covariant  Uint8Key key,
    bool withKey,
  ) {
    offset = key.writeKeyAndMeta(byteData, offset, withKey);
    byteData.setUint8(offset, value);
    return WriteMeta(byteData, offset + kByteLength);
  }

  @override
  int getLength(covariant Uint8Key key) => kByteLength;
}

class Int16Data extends StyleData<int> {
  Int16Data(super.value);

  @override
  StyleKey createKey(int key) {
    return Int8Key(key);
  }

  @override
  WriteMeta write(ByteData byteData, int offset,covariant  Int16Key key, bool withKey) {
    offset = key.writeKeyAndMeta(byteData, offset, withKey);
    byteData.setInt16(offset, value);
    return WriteMeta(byteData, offset + k16BitLength);
  }

  @override
  int getLength(covariant  Int16Key key) => k16BitLength;
}

class Uint16Data extends StyleData<int> {
  Uint16Data(super.value);

  @override
  StyleKey createKey(int key) {
    return Int8Key(key);
  }

  @override
  WriteMeta write(
    ByteData byteData,
    int offset,
      covariant   Uint16Key key,
    bool withKey,
  ) {
    offset = key.writeKeyAndMeta(byteData, offset, withKey);
    byteData.setUint16(offset, value);
    return WriteMeta(byteData, offset + k16BitLength);
  }

  @override
  int getLength(covariant Uint16Key key) => k16BitLength;
}

class UInt32Data extends StyleData<int> {
  UInt32Data(super.value);

  @override
  StyleKey createKey(int key) {
    return Int32Key(key);
  }

  @override
  WriteMeta write(
    ByteData byteData,
    int offset,
      covariant Uint32Key key,
    bool withKey,
  ) {
    offset = key.writeKeyAndMeta(byteData, offset, withKey);
    byteData.setUint32(offset, value);
    return WriteMeta(byteData, offset + k32BitLength);
  }

  @override
  int getLength(covariant Uint32Key key) => k32BitLength;
}

class Int32Data extends StyleData<int> {
  Int32Data(super.value);

  @override
  StyleKey createKey(int key) {
    return Int32Key(key);
  }

  @override
  WriteMeta write(
    ByteData byteData,
    int offset,
      covariant  Int32Key key,
    bool withKey,
  ) {
    offset = key.writeKeyAndMeta(byteData, offset, withKey);
    byteData.setInt32(offset, value);
    return WriteMeta(byteData, offset + k32BitLength);
  }

  @override
  int getLength(covariant Int32Key key) => k32BitLength;
}

class IntData extends StyleData<int> {
  IntData(super.value);

  @override
  StyleKey createKey(int key) {
    return IntKey(key);
  }

  @override
  WriteMeta write(
    ByteData byteData,
    int offset,
      covariant IntKey key,
    bool withKey,
  ) {
    offset = key.writeKeyAndMeta(byteData, offset, withKey);
    byteData.setInt64(offset, value);
    return WriteMeta(byteData, offset + k64BitLength);
  }

  @override
  int getLength(covariant IntKey key) => k64BitLength;
}

class BoolData extends StyleData<bool> {
  BoolData(super.value);

  @override
  StyleKey createKey(int key) {
    return BoolKey(key);
  }

  @override
  WriteMeta write(
    ByteData byteData,
    int offset,
    covariant BoolKey key,
    bool withKey,
  ) {
    offset = key.writeKeyAndMeta(byteData, offset, withKey);
    byteData.setUint8(offset, value ? 1 : 0);
    return WriteMeta(byteData, offset + kByteLength);
  }

  @override
  int getLength(covariant BoolKey key) => kByteLength;
}
