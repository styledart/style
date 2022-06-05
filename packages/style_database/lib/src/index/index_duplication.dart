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

import 'dart:collection';

import 'package:meta/meta.dart';

import '../exceptions.dart';


/// T indexed value type
/// K getKey return type
abstract class IndexValueStorage<V, K> {
  IndexValueStorage(this.key);

  ///
  String key;

  ///
  final HashMap<String, V> _idsValues = HashMap<String, V>();

  ///
  @mustCallSuper
  void add(String id, V value) {
    _idsValues[id] = value;
  }

  ///
  V? remove(String id) {
    var value = _idsValues[id];
    if (value != null) {
      _removeID(value, id);
    }
    return value;
  }

  ///
  V? getValue(String id) => _idsValues[id];

  K? getID(V value);

  void _removeID(V value, String id);


  @override
  String toString() => '$_idsValues';

}


/// Can value's multiple id
class MultipleValueStorage<T>
    extends IndexValueStorage<T, List<String>> {
  MultipleValueStorage({required String key}) : super(key);

  ///
  final HashMap<T, List<String>> _valueIds = HashMap<T, List<String>>();

  @override
  void add(String id, T value) {
    _valueIds[value] ??= <String>[];
    _valueIds[value]!.add(id);
    super.add(id, value);
  }

  @override
  List<String>? getID(T value) => _valueIds[value];

  @override
  void _removeID(T value, String id) {
    _valueIds[value]?.remove(id);
  }
}

class UniqueValueStorage<T> extends IndexValueStorage<T, String> {
  UniqueValueStorage({required String key}) : super(key);

  ///
  final HashMap<T, String> _valueIds = HashMap<T, String>();

  @override
  void add(String id, T value) {
    if (_valueIds[value] != null) {
      throw UniqueValueDuplicatedException(key, value);
    }
    _valueIds[value] = id;
    super.add(id, value);
  }

  @override
  String? getID(T value) => _valueIds[value];

  @override
  void _removeID(T value, String id) {
    _valueIds.remove(value);
  }
}
