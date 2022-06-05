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

import '../../offline/cache_options.dart';
import '../../offline/offline_operation_options.dart';
import '../../random.dart';
import '../modules.dart';
import 'access_result.dart';
import 'query.dart';

///
abstract class AccessImplementation {
  ///
  String get endpointPath => module.endpointPath;
  ///
  late AccessModule module;

  ///
  Future<ReadResult> read(String collection,
      {String? identifier, Query? query});

  ///
  Future<ReadMultipleResult> readMultiple(String collection, {Query? query});

  ///
  Future<CreateResult> create(String collection,
      {required Map<String, dynamic> data, String? identifier});

  ///
  Future<UpdateResult> update(String collection,
      {required Map<String, dynamic> data, Query? query, String? identifier});

  ///
  Future<ExistsResult> exists(String collection,
      {Query? query, String? identifier});

  ///
  Future<DeleteResult> delete(String collection,
      {Query? query, String? identifier});

  ///
  Future<CountResult> count(String collection, {Query? query});

  ///
  Future<AggregationResult> aggregate(String collection,
      {List<Map<String, dynamic>> pipeline});
}

///
abstract class AccessModule extends StyleModule {
  ///
  AccessModule(
      {String? key, required this.implementation, required this.endpointPath})
      : super(key: key ?? "access_${getRandomId(10)}") {
    implementation.module = this;
  }

  ///
  final String endpointPath;

  ///
  final AccessImplementation implementation;

  ///
  Future<ReadResult> read(String collection,
      {String? identifier, Query? query, CacheOptions? options}) {
    return implementation.read(collection,
        query: query, identifier: identifier);
  }

  ///
  Future<ReadMultipleResult> readMultiple(String collection,
      {Query? query, CacheOptions? cacheOptions}) {
    return implementation.readMultiple(collection, query: query);
  }

  ///
  Future<CreateResult> create(String collection,
      {required Map<String, dynamic> data,
      String? identifier,
      OfflineOperationOptions? offlineOperationOptions}) {
    return implementation.create(collection,
        data: data, identifier: identifier);
  }

  ///
  Future<UpdateResult> update(String collection,
      {required Map<String, dynamic> data,
      Query? query,
      String? identifier,
      OfflineOperationOptions? offlineOperationOptions}) {
    return implementation.update(collection,
        data: data, query: query, identifier: identifier);
  }

  ///
  Future<ExistsResult> exists(String collection,
      {Query? query, String? identifier, CacheOptions? cacheOptions}) {
    return implementation.exists(collection,
        identifier: identifier, query: query);
  }

  ///
  Future<DeleteResult> delete(String collection,
      {Query? query,
      String? identifier,
      OfflineOperationOptions? cacheOptions}) {
    return implementation.delete(collection,
        identifier: identifier, query: query);
  }

  ///
  Future<CountResult> count(String collection,
      {Query? query, String? identifier, CacheOptions? cacheOptions}) {
    return implementation.count(collection, query: query);
  }

  ///
  Future<AggregationResult> aggregate(String collection,
      {Query? query,
      String? identifier,
      OfflineOperationOptions? cacheOptions,
      required List<Map<String, dynamic>> pipeline}) {
    return implementation.aggregate(collection, pipeline: pipeline);
  }
}
