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

import 'access_language.dart';

///
abstract class SortExpression<L extends AccessLanguage> {

  ///
  SortExpression();

  /// AccessEvent is sort by key.<br>
  /// returns true if sorted ascending, <br>
  /// returns false if sorted descending, <br>
  /// returns null if not sorted by this key.
  bool? sortedByAsc(dynamic key) {
    if (sorts.containsKey(key)) {
      return sorts[key] == Sorting.ascending;
    }
    return null;
  }

  /// AccessEvent is sort by key.<br>
  /// returns true if sorted descending, <br>
  /// returns false if sorted ascending, <br>
  /// returns null if not sorted by this key.
  bool? sortedByDesc(dynamic key) {
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
