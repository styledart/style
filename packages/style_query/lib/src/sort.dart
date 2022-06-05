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

///
abstract class SortExpression<L extends AccessLanguage> {
  /// AccessEvent is sort by key.<br>
  /// returns true if sorted ascending, <br>
  /// returns false if sorted descending, <br>
  /// returns null if not sorted by this key.
  bool? sortedByAsc(String key) {
    if (sorts.containsKey(key)) {
      return sorts[key] == Sorting.ascending;
    }
    return null;
  }

  /// AccessEvent is sort by key.<br>
  /// returns true if sorted descending, <br>
  /// returns false if sorted ascending, <br>
  /// returns null if not sorted by this key.
  bool? sortedByDesc(String key) {
    if (sorts.containsKey(key)) {
      return sorts[key] == Sorting.descending;
    }
    return null;
  }

  ///
  Map<String, Sorting> get sorts;
}

///
enum Sorting {
  ///
  ascending,

  ///
  descending
}
