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

part of '../style_database_base.dart';

///
abstract class Storage<T extends Object> {
  ///
  Future<void> create(T object);

  ///
  T? read(String id);

  ///
  Iterator<String> get iterator;
}

class MemoryStorage<T extends Object> extends Storage<T> {
  final Map<String, T> _data = <String, T>{};

  @override
  Future<void> create(T object) async {
    _data[(object as JsonMap)[_idKey] as String] = object;
  }

  @override
  T? read(String id) => _data[id] as T;

  @override
  Iterator<String> get iterator => _data.keys.iterator;
}
