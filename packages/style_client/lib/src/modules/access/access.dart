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


import 'query.dart';

///
class Access {
  ///
  const Access(
      {this.query,
        this.identifier,
        required this.type,
        this.data,
        required this.collection,
        this.pipeline});

  ///
  factory Access.fromMap(Map<String, dynamic> map) {
    return Access(
        identifier: map["identifier"],
        data: map["data"],
        query: map["query"] == null ? null : Query.fromMap(map["query"]),
        type: AccessType.values[map["type"]],
        collection: map["collection"],

        /// May map contains "pipeline" key with null value
        /// This situation create empty pipeline
        pipeline: map["pipeline"]);
  }

  ///
  final Query? query;

  ///
  final Object? pipeline;

  ///
  final String? identifier;

  ///
  final AccessType type;

  ///
  final String collection;

  /// For create or update
  final Map<String, dynamic>? data;

  ///
  Map<String, dynamic> toMap() => {
    "collection": collection,
    "type": type.index,
    if (pipeline != null) "pipeline": pipeline,
    if (query != null) "query": query?.toMap(),
    if (identifier != null) "identifier": identifier,
  };
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
