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

import '../../offline/cache_information.dart';

/// Maybe will add some properties in future
abstract class AccessResult {
  ///
  AccessResult({required this.statusCode});

  /// Response status code
  int statusCode;

  ///
  void setCacheMetadata({required CacheMetadata cacheMetadata}) {
    this.cacheMetadata = cacheMetadata;
    onCache = true;
  }

  ///
  bool onCache = false;

  ///
  CacheMetadata? cacheMetadata;
}

///
class ReadResult extends AccessResult {
  ///
  ReadResult({required this.data, required int statusCode})
      : super(statusCode: statusCode);

  ///
  Map<String, dynamic> data;
}

///
class ReadMultipleResult extends AccessResult {
  ///
  ReadMultipleResult({required this.data, required int statusCode})
      : super(statusCode: statusCode);

  ///
  List<Map<String, dynamic>> data;
}

///
class CreateResult extends AccessResult {
  ///
  CreateResult({this.identifiers, required int statusCode})
      : super(statusCode: statusCode);

  ///
  int? get createdCount => identifiers?.length;

  ///
  String? get identifier =>
      identifiers?.isEmpty ?? false ? null : identifiers!.first;

  ///
  List<String>? identifiers;
}

///
class UpdateResult extends AccessResult {
  ///
  UpdateResult({this.identifiers, this.override, required int statusCode})
      : super(statusCode: statusCode);

  ///
  int? get updatedCount => identifiers?.length;

  ///
  String? get identifier =>
      identifiers?.isEmpty ?? false ? null : identifiers!.first;

  ///
  List<String>? identifiers;

  ///
  bool? override;
}

///
class ExistsResult extends AccessResult {
  ///
  ExistsResult({required this.exists, required int statusCode})
      : super(statusCode: statusCode);

  ///
  bool exists;
}

///
class DeleteResult extends AccessResult {
  ///
  DeleteResult({required this.exists, required int statusCode})
      : super(statusCode: statusCode);

  ///
  bool exists;
}

///
class CountResult extends AccessResult {
  ///
  CountResult({required this.count, required int statusCode})
      : super(statusCode: statusCode);

  ///
  int count;
}

///
class AggregationResult extends AccessResult {
  ///
  AggregationResult({required this.data, required int statusCode})
      : super(statusCode: statusCode);

  ///
  List<Map<String, dynamic>> data;
}
