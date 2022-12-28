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

import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../style_query.dart';

///
class QueryLanguageBinding {
  ///
  factory QueryLanguageBinding() => _binding;

  QueryLanguageBinding._();

  static final QueryLanguageBinding _binding = QueryLanguageBinding._();

  final Map<Type, AccessLanguageDelegate> _delegates = {};

  ///
  AccessLanguageDelegate<L> delegate<L extends AccessLanguage>() =>
      _delegates[L]! as AccessLanguageDelegate<L>;

  ///
  void initDelegate<T extends AccessLanguage>(
      AccessLanguageDelegate<T> delegate) {
    _delegates[T] = delegate;
  }

  ///
  Access<T> convertTo<T extends AccessLanguage>(Access access) {
    if (access.language == T) {
      return access as Access<T>;
    }
    var from = _delegates[T];

    if (from == null) {
      throw Exception(
          "Access language \"${access.language}\" not initialized.");
    }

    var common = from.toCommonLanguage(access);

    if (T == CommonLanguage) {
      return common as Access<T>;
    } else {
      var to = _delegates[T];
      if (to == null) {
        throw Exception("Access language $T not initialized.");
      }
      return to.fromCommonLanguage(common) as Access<T>;
    }
  }
}

///
@immutable
abstract class FieldKey<L extends AccessLanguage> {
  ///
  @override
  int get hashCode;

  ///
  @override
  bool operator ==(Object other);
}

///
abstract class AccessLanguage {
  ///
  const AccessLanguage();
}

/// R is raw data format.
///
/// This delegate allows R instances to be converted to general access
/// objects like [CreateData], [UpdateData] etc.
abstract class AccessLanguageDelegate<L extends AccessLanguage> {
  ///
  const AccessLanguageDelegate(this.name);

  ///
  final String name;

  ///
  CommonAccess toCommonLanguage(Access<L> access);

  ///
  Access<L> fromCommonLanguage(CommonAccess access);

  ///
  Access<L> accessFromJson(JsonMap jsonMap);

  ///
  Access<L> accessFromBinary(Uint8List binary) =>
      accessFromJson(binary.toJson());

  ///
  Query<L> queryFromJson(JsonMap jsonMap);

  ///
  Query<L> queryFromBinary(Uint8List binary) => queryFromJson(binary.toJson());

  ///
  UpdateData<L> updateDataFromJson(JsonMap jsonMap);

  ///
  UpdateData<L> updateDataFromBinary(Uint8List binary) =>
      updateDataFromJson(binary.toJson());

  ///
  CreateData<L> createDataFromJson(JsonMap jsonMap);

  ///
  CreateData<L> createDataFromBinary(Uint8List binary) =>
      createDataFromJson(binary.toJson());
}
