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

import '../style_query.dart';

///
class QueryLanguageBinding {
  ///
  factory QueryLanguageBinding() => _binding;

  QueryLanguageBinding._();

  static final QueryLanguageBinding _binding = QueryLanguageBinding._();

  final Map<Type, AccessLanguageDelegate> _delegates = {};

  ///
  void initDelegate<T extends AccessLanguage>(
      AccessLanguageDelegate<T> delegate) {
    _delegates[T] = delegate;
  }

  ///
  Access<T> convertTo<T extends AccessLanguage>(Access access) {
    print(access.language);
    print(T);

    if (access.language == T) {
      return access as Access<T>;
    }

    var from = _delegates[access.language];

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
abstract class AccessLanguage {
  ///
  String get name;
}

///
abstract class AccessLanguageDelegate<L extends AccessLanguage> {
  ///
  AccessLanguageDelegate();

  ///
  CreateData<L> createFromRaw(Map<String, dynamic> raw);

  ///
  UpdateData<L> updateFromRaw(Map<String, dynamic> raw);

  ///
  Pipeline<L> pipelineFromRaw(Map<String, dynamic> raw);

  ///
  Fields<L> fieldsFromRaw(Map<String, dynamic> raw);

  ///
  Query<L> queryFromRaw(Map<String, dynamic> raw);

  ///
  CommonAccess toCommonLanguage(Access<L> access);

  ///
  Access<L> fromCommonLanguage(CommonAccess access);
}
