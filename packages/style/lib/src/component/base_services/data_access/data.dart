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
typedef DbOperation<T extends DbResult> = FutureOr<T> Function(Access access);

///
abstract class DataAccess extends _BaseService {
  ///
  factory DataAccess(
    DataAccessImplementation implementation, {
    List<DbCollection>? collections,
    Map<DbOperationType, bool>? defaultPermissionsByType,
    bool defaultPermission = true,
    bool streamSupport = false,
  }) {
    var hasPermission = (collections
                ?.where((element) =>
                    element.permissionHandler != null || element.hasSchema)
                .isNotEmpty ??
            false) ||
        defaultPermissionsByType != null;

    var hasTrigger = collections
            ?.where((element) =>
                element.triggers != null && element.triggers!.isNotEmpty)
            .isNotEmpty ??
        false;
    Map<String, String>? identifierMapping;
    TriggerService? _triggerService;
    PermissionHandlerService? _permissionHandler;

    if (collections != null) {
      var hasIdentifier =
          collections.where((element) => element.identifier != null).isNotEmpty;

      if (hasIdentifier) {
        identifierMapping = {};
        for (var db in collections) {
          if (db.identifier != null) {
            identifierMapping[db.collectionName] = db.identifier!;
          }
        }
      }
    }

    if (hasPermission) {
      _permissionHandler = PermissionHandlerService.create(
          defaultPermission: defaultPermission,
          collections: collections,
          defaultRules: defaultPermissionsByType);
    }

    if (hasTrigger || streamSupport) {
      _triggerService = TriggerService.create(
          streamSupport: streamSupport, collections: collections);
    }

    if (collections?.isEmpty ?? true) {
      return _DataAccessEmpty(implementation, identifierMapping);
    } else if (_triggerService != null && _permissionHandler == null) {
      return _DataAccessWithOnlyTrigger(
          implementation, _triggerService, identifierMapping);
    } else if (_triggerService == null && _permissionHandler != null) {
      return _DataAccessWithPermission(
          implementation, _permissionHandler, identifierMapping);
    } else {
      return _DataAccessWithTriggerAndPermission(implementation,
          _triggerService!, _permissionHandler!, identifierMapping);
    }
  }

  ///
  final Map<String, String>? identifierMapping;

  ///
  DataAccess._(this.implementation,
      {this.permissionHandler, this.triggerService, this.identifierMapping})
      : _read = implementation.read,
        _readList = implementation.readList,
        _delete = implementation.delete,
        _update = implementation.update,
        _create = implementation.create,
        _exists = implementation.exists,
        _count = implementation.count,
        _initDb = implementation.init,
        _aggregation = implementation.aggregation {
    implementation.dataAccess = this;
    permissionHandler?.dataAccess = this;
    triggerService?.dataAccess = this;
  }

  ///
  static DataAccess of(BuildContext context) {
    return context.dataAccess;
  }

  ///
  DataAccessImplementation implementation;

  ///
  PermissionHandlerService? permissionHandler;

  ///
  TriggerService? triggerService;

  BuildContext get context => super.context;

  FutureOr<T> _operation<T extends DbResult>(
      AccessEvent accessEvent, FutureOr<T> Function() interoperation);

  ///
  FutureOr<DbResult> any(AccessEvent access) {
    switch (access.access.type) {
      case AccessType.read:
        return _operation(access, () => _read(access.access));
      case AccessType.readMultiple:
        return _operation(access, () => _readList(access.access));
      case AccessType.create:
        return _operation(access, () => _create(access.access));
      case AccessType.update:
        return _operation(access, () => _update(access.access));
      case AccessType.exists:
        return _operation(access, () => _exists(access.access));
      case AccessType.listen:
        throw UnimplementedError();
      case AccessType.delete:
        return _operation(access, () => _delete(access.access));
      case AccessType.count:
        return _operation(access, () => _count(access.access));
      case AccessType.aggregation:
        return _operation(access, () => _aggregation(access.access));
    }
  }

  ///
  FutureOr<ReadDbResult> read(AccessEvent access) {
    return _operation<ReadDbResult>(access, () => _read(access.access));
  }

  ///
  FutureOr<ReadListResult> readList(AccessEvent access) {
    return _operation<ReadListResult>(access, () => _readList(access.access));
  }

  ///
  FutureOr<ReadListResult> aggregation(AccessEvent access) {
    return _operation<ReadListResult>(
        access, () => _aggregation(access.access));
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

  // ///
  // FutureOr<ListenResult<Map<String, dynamic>>> listen(Query query) {
  //   throw UnimplementedError("implement override"
  //       " DataAccess.listen for use listen");
  // }

  ///
  final DbOperation<ReadDbResult> _read;

  ///
  final DbOperation<ReadListResult> _readList;

  ///
  final DbOperation<ReadListResult> _aggregation;

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

  ///
  Map<String, dynamic> toMap() => {
        "implementation": implementation.runtimeType,
        "data_access": runtimeType,
        "wrapper": (context as Binding).key.key
      };
}

class _DataAccessWithTriggerAndPermission extends DataAccess {
  _DataAccessWithTriggerAndPermission(
      DataAccessImplementation implementation,
      TriggerService triggerService,
      PermissionHandlerService permissionHandler,
      Map<String, String>? identifierMapping)
      : super._(implementation,
            triggerService: triggerService,
            permissionHandler: permissionHandler,
            identifierMapping: identifierMapping);

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
  _DataAccessWithOnlyTrigger(DataAccessImplementation implementation,
      TriggerService triggerService, Map<String, String>? identifierMapping)
      : super._(implementation,
            triggerService: triggerService,
            identifierMapping: identifierMapping);

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
  _DataAccessEmpty(DataAccessImplementation implementation,
      Map<String, String>? identifierMapping)
      : super._(implementation, identifierMapping: identifierMapping);

  @override
  FutureOr<T> _operation<T extends DbResult>(
      AccessEvent access, FutureOr<T> Function() interoperation) {
    return interoperation();
  }
}

class _DataAccessWithPermission extends DataAccess {
  _DataAccessWithPermission(
      DataAccessImplementation implementation,
      PermissionHandlerService permissionHandler,
      Map<String, String>? identifierMapping)
      : super._(implementation,
            permissionHandler: permissionHandler,
            identifierMapping: identifierMapping);

  @override
  FutureOr<T> _operation<T extends DbResult>(
      AccessEvent access, FutureOr<T> Function() interoperation) async {
    try {
      if (await permissionHandler!.check(access)) {
        return interoperation();
      } else {
        throw ForbiddenUnauthorizedException()..payload = access.toMap(false);
      }
    } on Exception {
      rethrow;
    }
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

  ///
  aggregation
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
        pipeline: !map.containsKey("pipeline")
            ? null
            : AggregationPipeline.fromMap(map["pipeline"]));
  }

  ///
  final Query? query;

  ///
  final AggregationPipeline? pipeline;

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
        if (pipeline != null) "pipeline": pipeline?.toMap(),
        if (query != null) "query": query?.toMap(),
        if (identifier != null) "identifier": identifier,
      };
}

///
class AggregationPipeline {
  ///
  AggregationPipeline(this.stages);

  ///
  /// Example map:
  /// ```json
  /// {
  ///   "type" : {
  ///     ...data
  ///   }
  /// }
  /// ```
  factory AggregationPipeline.fromMap(Map<String, dynamic>? map) {
    return AggregationPipeline(
        map?.entries.map((e) => AggregationStage(e.key, e.value)).toList() ??
            <AggregationStage>[]);
  }

  ///
  List<AggregationStage> stages;

  ///
  bool hasStage(String type) {
    return stages.where((element) => element.type == type).isNotEmpty;
  }

  ///
  List<String> get stageTypes => stages.map((e) => e.type).toList();

  ///
  Map<String, dynamic> toMap() =>
      stages.asMap().map((key, value) => MapEntry(value.type, value.data));
}

///
class AggregationStage {
  ///
  AggregationStage(this.type, this.data);

  ///
  String type;

  ///
  Map<String, dynamic> data;
}

///
class Read extends AccessEvent {
  ///
  Read(
      {Request? request,
      required String collection,
      String? identifier,
      Query? query,
      AccessToken? customToken})
      : assert(identifier != null || query != null),
        super(
            request: request?..token = customToken,
            access: Access(
                type: AccessType.read,
                collection: collection,
                identifier: identifier,
                query: query));
}

///
class ReadMultiple extends AccessEvent {
  ///
  ReadMultiple(
      {Request? request,
      required String collection,
      Query? query,
      AccessToken? customToken})
      : super(
            request: request?..token = customToken,
            access: Access(
                type: AccessType.readMultiple,
                collection: collection,
                query: query));
}

///
class Create extends AccessEvent {
  ///
  Create(
      {Request? request,
      required String collection,
      required Map<String, dynamic> data,
      AccessToken? customToken})
      : super(
            request: request?..token = customToken,
            access: Access(
                type: AccessType.create, collection: collection, data: data));
}

///
class Update extends AccessEvent {
  ///
  Update(
      {Request? request,
      required String collection,
      Query? query,
      String? identifier,
      required Map<String, dynamic> data,
      AccessToken? customToken})
      : assert(identifier != null || query != null),
        super(
            request: request?..token = customToken,
            access: Access(
                type: AccessType.update, collection: collection, data: data));
}

///
class Delete extends AccessEvent {
  ///
  Delete(
      {Request? request,
      required String collection,
      String? identifier,
      Query? query,
      AccessToken? customToken})
      : assert(identifier != null || query != null),
        super(
            request: request?..token = customToken,
            access: Access(
                type: AccessType.delete,
                collection: collection,
                identifier: identifier,
                query: query));
}

///
class Count extends AccessEvent {
  ///
  Count(
      {Request? request,
      required String collection,
      Query? query,
      AccessToken? customToken})
      : super(
          request: request?..token = customToken,
          access: Access(
              type: AccessType.count, collection: collection, query: query),
        );
}

///
class Exists extends AccessEvent {
  ///
  Exists(
      {Request? request,
      required String collection,
      Query? query,
      String? identifier,
      AccessToken? customToken})
      : assert(identifier != null || query != null),
        super(
            request: request?..token = customToken,
            access: Access(
                identifier: identifier,
                type: AccessType.exists,
                collection: collection,
                query: query));
}

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

///
abstract class DataAccessImplementation {
  ///
  FutureOr<bool> init();

  ///
  FutureOr<DbResult> any(AccessEvent event) {
    switch (event.access.type) {
      case AccessType.read:
        return read(event.access);
      case AccessType.readMultiple:
        return readList(event.access);
      case AccessType.create:
        return create(event.access);
      case AccessType.update:
        return update(event.access);
      case AccessType.exists:
        return exists(event.access);
      case AccessType.listen:
        throw UnimplementedError();
      case AccessType.aggregation:
        return aggregation(event.access);
      case AccessType.delete:
        return delete(event.access);
      case AccessType.count:
        return count(event.access);
    }
  }

  ///
  FutureOr<ReadDbResult> read(Access access);

  ///
  FutureOr<ReadListResult> readList(Access access);

  ///
  FutureOr<ReadListResult> aggregation(Access access);

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

  // ///
  // FutureOr<ListenResult<Map<String, dynamic>>> listen(
  //     Query query, Map<String, dynamic> document) {
  //   throw UnimplementedError("implement override"
  //       " DataAccess.listen for use listen");
  // }

  ///
  BuildContext get context => dataAccess.context;

  ///
  late final DataAccess dataAccess;
}

///
typedef BoolDbResult = DbResult<bool>;

///
typedef CountDbResult = DbResult<int>;

// ///
// typedef ListenResult<T> = DbResult<StreamController<T>>;

///
typedef ReadDbResult = DbResult<Map<String, dynamic>?>;

///
typedef ArrayDbResult<T> = DbResult<List<T>?>;

///
typedef ReadListResult = ArrayDbResult<Map<String, dynamic>>;

///
typedef AggregationResult = ArrayDbResult<Map<String, dynamic>>;

/// Database Operation Result
class DbResult<T> {
  ///
  DbResult(
      {required this.data, this.statusCode, this.headers, this.success = true});

  /// Operation is success
  bool success;

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
  CreateDbResult({required this.identifier})
      : super(
            data: null,
            statusCode: 201,
            headers: {HttpHeaders.locationHeader: identifier});

  ///
  dynamic identifier;
}

///
class DeleteDbResult extends DbResult<Map<String, dynamic>?> {
  ///
  DeleteDbResult({required bool exists})
      : super(data: null, statusCode: exists ? 200 : 404);
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
    if (access.data == null) {
      throw BadRequests();
    }
    String id;
    if (access.identifier == null &&
        access.data!["_id"] == null &&
        access.data!["id"] == null) {
      id = getRandomId(30);
      access.data!["_id"] = id;
    }
    id = access.identifier ?? access.data!["id"] ?? access.data!["_id"]!;
    data[access.collection] ??= {};
    data[access.collection]![id] = access.data!;
    return CreateDbResult(identifier: id);
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
    }
    var d = data[access.collection]?[access.identifier];

    return ReadDbResult(data: d == null ? null : Map<String, dynamic>.from(d));
  }

  @override
  FutureOr<ReadListResult> readList(Access access) {
    if (access.query?.selector != null) {
      Logger.of(context).warn(context, "query_not_supported",
          title: "Query selector "
              "not supported with SimpleCacheDataAccess , so its skipped");
    }

    if (access.query?.sort != null) {
      Logger.of(context).warn(context, "sort_not_supported",
          title: "Query sort "
              "not supported with SimpleCacheDataAccess , so its skipped");
    }
    if (access.query?.fields != null) {
      Logger.of(context).warn(context, "sort_not_supported",
          title: "Query fields "
              "not supported with SimpleCacheDataAccess , so its skipped");
    }
    var l = access.query?.limit ?? 200;
    var s = access.query?.offset ?? 0;

    var len = data[access.collection]?.length ?? 0;

    var nLen = len - s;

    if (nLen <= 0) {
      return ReadListResult(data: []);
    }

    if (l >= nLen) {
      l = nLen;
    }

    return ReadListResult(
        data: _copy(
            data[access.collection]?.values.toList().sublist(s).sublist(0, l)));
  }

  List<T>? _copy<T>(List<T>? l) {
    if (l == null) return null;
    return List<T>.from(l);
  }

  @override
  FutureOr<UpdateDbResult> update(Access access) {
    if (access.data == null) {
      throw BadRequests();
    }
    if (access.identifier == null) {
      throw BadRequests();
    }
    data[access.collection]?[access.identifier]?.addAll(access.data!);
    return UpdateDbResult(data: null);
  }

  @override
  FutureOr<DbResult<int>> count(Access access) {
    if (access.query != null) {
      Logger.of(context).warn(context, "query_not_supported",
          title: "Query "
              "not supported with SimpleCacheDataAccess , so its skipped");
    }
    return DbResult<int>(data: data[access.collection]?.length ?? 0);
  }

  @override
  FutureOr<DbResult<bool>> exists(Access access) {
    // TODO: implement exists
    if (access.query != null) {
      Logger.of(context).warn(context, "query_not_supported",
          title: "Query "
              "not supported with SimpleCacheDataAccess , so its skipped");
    }

    if (access.identifier == null) {
      throw BadRequests();
    }

    return DbResult<bool>(
        data: data[access.collection]?[access.identifier!] != null);
  }

  @override
  FutureOr<ReadListResult> aggregation(Access access) {
    throw UnimplementedError(
        "Aggregation not supported with Simple(Cache)DataAccess");
  }
}

///
class SimpleDataAccess extends SimpleCacheDataAccess {
  ///
  SimpleDataAccess(this.directory)
      : assert(directory.endsWith(Platform.pathSeparator) ||
            directory.endsWith("/"));

  ///
  String directory;

  Future<bool> init([bool inInterface = true]) async {
    var docs = await Directory(directory)
        .list()
        .where((event) => event.path.endsWith(".json"))
        .toList();

    var colsFtrs =
        docs.map((e) async => json.decode(await File(e.path).readAsString()));
    var cols = await Future.wait(colsFtrs);
    var i = 0;
    while (i < cols.length) {
      data[docs[i].path.split("/").last.replaceAll(".json", "")] =
          (cols[i] as Map).cast<String, Map<String, dynamic>>();
      i++;
    }
    return true;
  }

  ///
  Future<void> saveCollection(String collection) async {
    var f = File("$directory$collection.json");
    if (!(await f.exists())) {
      await f.create();
    }
    f.writeAsString(json.encode(data[collection]));
  }

  @override
  FutureOr<CreateDbResult> create(Access access) async {
    var res = await super.create(access);

    saveCollection(access.collection);

    return res;
  }

  @override
  FutureOr<UpdateDbResult> update(Access access) async {
    var res = await super.update(access);

    saveCollection(access.collection);

    return res;
  }

  @override
  FutureOr<DeleteDbResult> delete(Access access) async {
    var res = await super.delete(access);

    saveCollection(access.collection);

    return res;
  }
}
