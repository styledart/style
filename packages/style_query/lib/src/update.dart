/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import 'access_language.dart';
import 'access_object.dart';

///
abstract class UpdateData<L extends AccessLanguage> with AccessObject {
  ///
  UpdateDifference<T>? difference<T>(String key);

  ///
  Map<String, UpdateDifference> differences();

  ///
  List<String> keysRenamed();

  ///
  List<String> fieldsChanged();

  ///
  List<String> fieldsRemoved();

  ///
  bool isChangedField(String key) {
    return fieldsChanged().contains(key);
  }

  ///
  bool keyIsRenamed(String key) {
    return keysRenamed().contains(key);
  }

  ///
  bool keyRemoved(String key) {
    return fieldsRemoved().contains(key);
  }
}

///
enum DifferenceType {
  ///
  set,

  ///
  remove,

  ///
  increment,

  /// Insert object to array
  insert,

  ///
  removeArrayObj
}

///
abstract class UpdateDifference<T> {
  ///
  DifferenceType get type;

  ///
  String get key;
}

///
class SetFieldsDifference<T> extends UpdateDifference<T> {
  ///
  SetFieldsDifference(this._key, this.newValue);

  ///
  T newValue;

  ///
  final String _key;

  @override
  String get key => _key;

  @override
  DifferenceType get type => DifferenceType.set;
}

//TODO: Implement other type of differences
