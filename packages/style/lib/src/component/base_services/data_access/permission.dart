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
part of '../../../style_base.dart';

///
typedef PermissionChecker = Map<String, Map<DbOperationType, Checker>> Function(
    Access access);

///
typedef Checker = Future<bool> Function();



///
class PermissionHandlerService {
  ///
  PermissionHandlerService.create(
      {bool defaultPermission = true,
      Map<DbOperationType, bool>? defaultRules,
      List<DbCollection>? collections})
      : _defaultRules = defaultRules ??
            DbOperationType.values
                .asMap()
                .map((key, value) => MapEntry(value, defaultPermission)),
        _collections = HashMap.from(collections
                ?.where((element) => element.permissionHandler != null)
                .toList()
                .asMap()
                .map((key, value) =>
                    MapEntry(value.collectionName, value.permissionHandler)) ??
            {}) {
    for (var r in DbOperationType.values) {
      _defaultRules[r] ??= defaultPermission;
    }
  }

  ///
  @visibleForOverriding
  late final DataAccess dataAccess;

  /// Default Rule For All Fields by Operation Type
  final Map<DbOperationType, bool> _defaultRules;

  ///
  final HashMap<String, PermissionHandler> _collections;

  ///
  FutureOr<bool> check(AccessEvent operation) async {
    var befNeed = _collections[operation.access.collection]?.beforeNeed;
    if (befNeed == null) {
      return _defaultRules[operation.type]!;
    }
    if (befNeed) {
      operation.before ??= (await dataAccess._read.call(operation.access)).data;
    }
    return _collections[operation.access.collection]!.checker(operation);
  }
}
