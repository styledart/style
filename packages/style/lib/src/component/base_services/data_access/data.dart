/*
 * Copyright (c) 2021. This code was written by Mehmet Yaz.
 * Mehmet Yaz does not accept the problems that may arise due to these codes.
 */

part of '../../../style_base.dart';

///
typedef DbOperation<T extends DbResult> = FutureOr<T> Function(Access access);

///
abstract class DataAccess extends _BaseService {
  ///
  factory DataAccess(DataAccessImplementation implementation,
      {List<DbCollection>? collections,
      Map<DbOperationType, bool>? defaultPermissionsByType,
      bool defaultPermission = true,
      bool streamSupport = false}) {
    var hasPermission = (collections
                ?.where((element) => element.permissionHandler != null)
                .isNotEmpty ??
            false) ||
        defaultPermissionsByType != null;

    var hasTrigger = collections
            ?.where((element) =>
                element.triggers != null && element.triggers!.isNotEmpty)
            .isNotEmpty ??
        false;

    TriggerService? _triggerService;
    PermissionHandlerService? _permissionHandler;

    if (hasPermission) {
      _permissionHandler = PermissionHandlerService.create(
          defaultPermission: defaultPermission,
          collections: collections,
          defaultRules: defaultPermissionsByType);
    }

    if (hasTrigger) {
      _triggerService = TriggerService.create(
          streamSupport: streamSupport, collections: collections);
    }

    if (collections?.isEmpty ?? true) {
      return _DataAccessEmpty(implementation);
    } else if (_triggerService != null && _permissionHandler == null) {
      return _DataAccessWithOnlyTrigger(implementation, _triggerService);
    } else if (_triggerService == null && _permissionHandler != null) {
      return _DataAccessWithPermission(implementation, _permissionHandler);
    } else {
      return _DataAccessWithTriggerAndPermission(
          implementation, _triggerService!, _permissionHandler!);
    }
  }

  ///
  DataAccess._(DataAccessImplementation implementation,
      {this.permissionHandler, this.triggerService})
      : _read = implementation.read,
        _readList = implementation.readList,
        _delete = implementation.delete,
        _update = implementation.update,
        _create = implementation.create,
        _exists = implementation.exists,
        _count = implementation.count,
        _initDb = implementation.init;

  ///
  PermissionHandlerService? permissionHandler;

  ///
  TriggerService? triggerService;

  FutureOr<T> _operation<T extends DbResult>(
      AccessEvent accessEvent, FutureOr<T> Function() interoperation);

  ///
  FutureOr<ReadDbResult> read(AccessEvent access) {
    return _operation<ReadDbResult>(access, () => _read(access.access));
  }

  ///
  FutureOr<ReadListResult> readList(AccessEvent access) {
    return _operation<ReadListResult>(access, () => _readList(access.access));
  }

  ///
  FutureOr<DbResult<bool>> exists(AccessEvent access) {
    return _operation<DbResult<bool>>(access, () => _exists(access.access));
  }

  ///
  FutureOr<DeleteDbResult> delete(AccessEvent access) {
    return _operation<DeleteDbResult>(access, () => _delete(access.access));
  }

  ///
  FutureOr<UpdateDbResult> update(AccessEvent access) {
    return _operation<UpdateDbResult>(access, () => _update(access.access));
  }

  ///
  FutureOr<CreateDbResult> create(AccessEvent access) {
    return _operation<CreateDbResult>(access, () => _create(access.access));
  }

  ///
  FutureOr<DbResult<int>> count(AccessEvent access) {
    return _operation<DbResult<int>>(access, () => _count(access.access));
  }

  ///
  FutureOr<ListenResult<Map<String, dynamic>>> listen(Query query) {
    throw UnimplementedError("implement override"
        " DataAccess.listen for use listen");
  }

  ///
  final DbOperation<ReadDbResult> _read;

  ///
  final DbOperation<ReadListResult> _readList;

  ///
  final DbOperation<DeleteDbResult> _delete;

  ///
  final DbOperation<UpdateDbResult> _update;

  ///
  final DbOperation<CreateDbResult> _create;

  final FutureOr<DbResult<bool>> Function(Access access) _exists;

  ///
  final FutureOr<DbResult<int>> Function(Access access) _count;

  final FutureOr<bool> Function() _initDb;

  @override
  FutureOr<bool> init([bool inInterface = true]) {
    return _initDb();
  }
}

class _DataAccessWithTriggerAndPermission extends DataAccess {
  _DataAccessWithTriggerAndPermission(DataAccessImplementation implementation,
      TriggerService triggerService, PermissionHandlerService permissionHandler)
      : super._(implementation,
            triggerService: triggerService,
            permissionHandler: permissionHandler);

  @override
  FutureOr<T> _operation<T extends DbResult>(
      AccessEvent accessEvent, FutureOr<T> Function() interoperation) async {
    if (await permissionHandler!.check(accessEvent)) {
      return triggerService!.triggerAndReturn(accessEvent, interoperation);
    } else {
      throw ForbiddenUnauthorizedException();
    }
  }
}

class _DataAccessWithOnlyTrigger extends DataAccess {
  _DataAccessWithOnlyTrigger(
      DataAccessImplementation implementation, TriggerService triggerService)
      : super._(implementation, triggerService: triggerService);

  @override
  FutureOr<T> _operation<T extends DbResult>(
      AccessEvent access, FutureOr<T> Function() interoperation) {
    try {
      return triggerService!.triggerAndReturn(access, interoperation);
    } on Exception {
      rethrow;
    }
  }
}

class _DataAccessEmpty extends DataAccess {
  _DataAccessEmpty(DataAccessImplementation implementation)
      : super._(implementation);

  @override
  FutureOr<T> _operation<T extends DbResult>(
      AccessEvent access, FutureOr<T> Function() interoperation) {
    return interoperation();
  }
}

class _DataAccessWithPermission extends DataAccess {
  _DataAccessWithPermission(DataAccessImplementation implementation,
      PermissionHandlerService permissionHandler)
      : super._(implementation, permissionHandler: permissionHandler);

  @override
  FutureOr<T> _operation<T extends DbResult>(
      AccessEvent access, FutureOr<T> Function() interoperation) async {
    try {
      if (await permissionHandler!.check(access)) {
        return interoperation();
      } else {
        throw ForbiddenUnauthorizedException();
      }
    } on Exception {
      rethrow;
    }
  }
}

///
class SimpleCacheDataAccess extends DataAccessImplementation {
  ///
  final Map<String, Map<String, Map<String, dynamic>>> data = {};

  @override
  Future<bool> init([bool inInterface = true]) async {
    return true;
  }

  @override
  FutureOr<CreateDbResult> create(Access access) {
    access.data!["_id"] ??= getRandomId(30);
    data[access.collection] ??= {};
    data[access.collection]![access.data!["_id"]] = access.data!;
    return CreateDbResult(
        identifier: access.data!["_id"],
        createdData: data[access.collection]![access.data!["_id"]]);
  }

  @override
  FutureOr<DeleteDbResult> delete(Access access) {
    if (access.identifier == null) {
      throw BadRequests();
    }
    if (data[access.collection]?[access.identifier!] == null) {
      return DeleteDbResult(exists: false);
    } else {
      data[access.collection]!.remove(access.identifier);
      return DeleteDbResult(exists: true);
    }
  }

  @override
  Future<ReadDbResult> read(Access access) async {
    if (access.identifier == null) {
      throw BadRequests();
    } else {
      var d = data[access.collection]?[access.identifier];
      print("DATA: $d");
      return ReadDbResult(data: d);
    }
  }

  @override
  FutureOr<ReadListResult> readList(Access access) {
    var d = data[access.collection];
    return ReadListResult(data: d?.values.toList());
  }

  @override
  Future<UpdateDbResult> update(Access access) {
    // TODO: implement update
    throw UnimplementedError();
  }

  @override
  FutureOr<DbResult<int>> count(Access access) {
    // TODO: implement count
    throw UnimplementedError();
  }

  @override
  FutureOr<DbResult<bool>> exists(Access access) {
    // TODO: implement exists
    throw UnimplementedError();
  }
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
}

///
@immutable
class Access {
  ///
  const Access(
      {this.query,
      this.identifier,
      required this.type,
      this.data,
      required this.collection});

  ///
  final Query? query;

  ///
  final String? identifier;

  ///
  final AccessType type;

  ///
  final String collection;

  /// For create or update
  final Map<String, dynamic>? data;
}

///
class Query {
  ///
  Query({this.selector, this.fields, this.limit, this.offset, this.sort});

  ///
  Map<String, dynamic>? selector, filter, sort, fields;

  ///
  int? limit, offset;
}

///
abstract class DataAccessImplementation {
  ///
  FutureOr<bool> init();

  ///
  FutureOr<ReadDbResult> read(Access access);

  ///
  FutureOr<ReadListResult> readList(Access access);

  ///
  FutureOr<DeleteDbResult> delete(Access access);

  ///
  FutureOr<UpdateDbResult> update(Access access);

  ///
  FutureOr<CreateDbResult> create(Access access);

  ///
  FutureOr<DbResult<bool>> exists(Access access);

  ///
  FutureOr<DbResult<int>> count(Access access);

  ///
  FutureOr<ListenResult<Map<String, dynamic>>> listen(
      Query query, Map<String, dynamic> document) {
    throw UnimplementedError("implement override"
        " DataAccess.listen for use listen");
  }
}

///
typedef BoolDbResult = DbResult<bool>;

///
typedef CountDbResult = DbResult<int>;

///
typedef ListenResult<T> = DbResult<StreamController<T>>;

///
typedef ReadDbResult = DbResult<Map<String, dynamic>?>;

///
typedef ArrayDbResult<T> = DbResult<List<T>?>;

///
typedef ReadListResult = ArrayDbResult<Map<String, dynamic>>;

///
typedef AggregationResult = ArrayDbResult<Map<String, dynamic>>;

///
typedef DistinctResult<T> = ArrayDbResult<T>;

/// Database Operation Result
class DbResult<T> {
  ///
  DbResult({required this.data, this.statusCode, this.headers});

  /// Operation is success
  late bool success;

  ///
  T data;

  ///
  int? statusCode;

  ///
  Map<String, dynamic>? headers;
}

///
class UpdateDbResult extends DbResult<Map<String, dynamic>?> {
  ///
  UpdateDbResult({Map<String, dynamic>? data, this.newData})
      : super(data: data);

  ///
  Map<String, dynamic>? newData;
}

///
class CreateDbResult extends DbResult<Map<String, dynamic>?> {
  ///
  CreateDbResult({this.createdData, required this.identifier})
      : super(
            data: createdData,
            statusCode: createdData != null ? 200 : 201,
            headers: {HttpHeaders.locationHeader: identifier});

  ///
  dynamic identifier;

  ///
  Map<String, dynamic>? createdData;
}

///
class DeleteDbResult extends DbResult<Map<String, dynamic>?> {
  ///
  DeleteDbResult({required bool exists})
      : super(data: null, statusCode: exists ? 200 : 404);
}
