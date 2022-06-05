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

import '../style_query.dart';
import 'access_object.dart';

///
abstract class Query<L extends AccessLanguage> with AccessObject {
  /// AccessEvent is sort by key.<br>
  /// returns true if sorted ascending, <br>
  /// returns false if sorted descending, <br>
  /// returns null if not sorted by this key.
  bool? sortedByAsc(String key) {
    return sortExpression?.sortedByAsc(key) ?? false;
  }

  /// is this query specified response fields by the [key]
  /// returns true if [key] specified as exclude
  /// returns false if [key] specified as include
  /// returns null if [key] not specified
  bool? fieldIsExcluded(String key) {
    if (fields?.excludeKeys != null) {
      return fields!.excludeKeys!.contains(key);
    }

    if (fields?.includeKeys != null) {
      return !fields!.includeKeys!.contains(key);
    }

    return null;
  }

  /// is this query specified response fields by the [key]
  /// returns true if [key] specified as include
  /// returns false if [key] specified as exclude
  /// returns null if [key] not specified any exclude/include
  bool? fieldIsIncluded(String key) {
    if (fields?.includeKeys != null) {
      return fields!.includeKeys!.contains(key);
    }

    if (fields?.excludeKeys != null) {
      return !fields!.excludeKeys!.contains(key);
    }

    return null;
  }

  /// return null if not filtered
  FilterExpression? filteredBy(String key) {
    if (filter is LogicalExpression) {
      return (filter as LogicalExpression).filteredBy(key);
    } else {
      return (filter as MatchExpression).key == key ? filter : null;
    }
  }

  /// The query querying exact document / entry
  bool get exactDocument => identifier != null;

  ///
  FilterExpression? get filter;

  /// Response fields manipulates
  Fields<L>? get fields;

  ///
  SortExpression? get sortExpression;

  /// Response fields manipulates
  set fields(Fields<L>? value);

  /// Query known object
  String? get identifier;

  /// Document limit
  int? get limit;

  /// Set document limit
  set limit(int? value);

  /// Document offset
  int? get offset;

  /// Set document offset
  set offset(int? value);
}
