/*
 * Copyright (c) 2021. This code was written by Mehmet Yaz.
 * Mehmet Yaz does not accept the problems that may arise due to these codes.
 */
part of '../../../style_base.dart';

///
typedef PermissionChecker = Map<String, Map<DbOperationType, Checker>> Function(
    Access access);

///
typedef Checker = Future<bool> Function();

///Mongo Db Operation Type
enum DbOperationType {
  ///Create Document
  create,

  ///Read Document
  read,

  ///Update Document
  update,

  ///Delete Document
  delete,
}

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
      operation.before = (await dataAccess._read.call(operation.access)).data;
    }
    return _collections[operation.access.collection]!.checker(operation);
  }
}
