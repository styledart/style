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

import 'dart:convert';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'access_language.dart';
import 'access_object.dart';
import 'create.dart';
import 'pipeline.dart';
import 'query.dart';
import 'settings.dart';
import 'update.dart';

///
typedef JsonMap = Map<String, dynamic>;


///
extension JsonToBinary on JsonMap {
  ///
  Uint8List toBinary() => utf8.encode(jsonEncode(this)) as Uint8List;

  ///
  String toJson() => jsonEncode(this);
}


///
extension BinaryToJson on Uint8List {
  ///
  JsonMap toJson() => jsonDecode(utf8.decode(this)) as JsonMap;
}

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
abstract class Access<L extends AccessLanguage> with AccessObject {
  ///
  const Access(
      {this.query,
      required this.type,
      required this.collection,
      this.pipeline,
      this.settings,
      this.createData,
      this.updateData});

  /// Access language
  Type get language => L;

  ///
  final Query<L>? query;

  ///
  final Pipeline<L>? pipeline;

  ///
  final OperationSettings? settings;

  ///
  final CreateData<L>? createData;

  ///
  final UpdateData<L>? updateData;

  ///
  final AccessType type;

  ///
  final String collection;
}
