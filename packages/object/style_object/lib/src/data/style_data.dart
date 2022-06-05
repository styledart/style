/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE, Version 3 (the "License");
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

class DataRead<T> {
  DataRead({required this.data, required this.offset});

  T data;

  int offset;
}

abstract class StyleData<T> {
  StyleData(this.value);

  factory StyleData.create(Object? value) {
    if (value is StyleData) {
      return value as StyleData<T>;
    } else if (value is int) {
      return IntData(value) as StyleData<T>;
    } else if (value is bool) {
      return BoolData(value) as StyleData<T>;
    } else if (value is String) {
      return StringData(value) as StyleData<T>;
    } else if (value is Map) {
      if (value is Map<int, StyleData>) {
        return StyleObjectWithKeys(value) as StyleData<T>;
      } else if (value is Map<String, StyleData>) {
        throw UnimplementedError();
      }
    } else if (value is List) {
      if (value is List<int>) {
        return Int64ListData(value) as StyleData<T>;
      } else if (value is List<double>) {
        //TODO:
        throw UnimplementedError();
      } else {
        return ListData(value) as StyleData<T>;
      }
    }

    throw 0;
  }

  T value;

  //late StyleKey key;

  int getLength(KeyFactory<T> key);

  WriteMeta write(
      ByteData byteData, int offset, KeyFactory<T> key, bool withKey);

  KeyFactory createKey(int key);
}
