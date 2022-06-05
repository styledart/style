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

import 'package:meta/meta.dart';

import 'access_language.dart';
import 'create.dart';
import 'pipeline.dart';
import 'query.dart';
import 'settings.dart';
import 'update.dart';

///
typedef JsonMap = Map<String, dynamic>;

///
enum AccessType {
  ///
  read,

  ///
  readMultiple,

  ///
  create,

  ///
  update,

  ///
  exists,

  ///
  listen,

  ///
  delete,

  ///
  count,

  ///
  aggregation
}

/// A request to access the database / a collection in the database.
/// Any CRUD operations, aggregations,
/// or other operations are defined as [Access].
///
@immutable
class Access<L extends AccessLanguage> {
  ///
  const Access(
      {this.query,
      required this.type,
      this.create,
      this.update,
      required this.collection,
      this.pipeline,
      this.settings});

  /// Access language
  Type get language => L;

  ///
  final Query<L>? query;

  ///
  final Pipeline<L>? pipeline;

  ///
  final OperationSettings? settings;

  ///
  final AccessType type;

  ///
  final String collection;

  ///
  final CreateData<L>? create;

  ///
  final UpdateData<L>? update;

  ///
  JsonMap toMap() => {
        "collection": collection,
        "type": type.index,
        if (create != null) "create": create!.toMap(),
        if (update != null) "update": update!.toMap(),
        if (pipeline != null) "pipeline": pipeline!.toMap(),
        if (query != null) "query": query!.toMap(),
      };
}
