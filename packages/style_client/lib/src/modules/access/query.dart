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

///
class Query {
  ///
  Query({this.selector, this.fields, this.limit, this.offset, this.sort});

  ///
  Map<String, dynamic>? selector, sort, fields;

  ///
  int? limit, offset;

  ///
  factory Query.fromMap(Map<String, dynamic> map) {
    return Query(
      fields: map["fields"],
      sort: map["sort"],
      offset: map["offset"],
      limit: map["limit"],
      selector: map["selector"],
    );
  }

  ///
  Map<String, dynamic> toMap() => {
        if (fields != null) "fields": fields,
        if (sort != null) "sort": sort,
        if (offset != null) "offset": offset,
        if (limit != null) "limit": limit,
        if (selector != null) "selector": selector
      };
}
