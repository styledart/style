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

part of '../../../style_base.dart';

///
typedef DbOperation<T extends DbResult> = FutureOr<T> Function(Access access);

///
abstract class DataAccess<L extends AccessLanguage> extends BaseService {
  ///
  factory DataAccess(
    DataAccessImplementation implementation, {
    List<DbCollection>? collections,
    Map<DbOperationType, bool>? defaultPermissionsByType,
    bool defaultPermission = true,
  }) {
    /// set permission handler if
    /// or
    /// -- any collection have custom permission
    /// -- defaultPermissionsByType is not null
    /// -- defaultPermission is false
    var hasPermission = (collections
                ?.where((element) =>
                    element.permissionHandler != null || element.hasSchema)
                .isNotEmpty ??
            false) ||
        defaultPermissionsByType != null ||
        !defaultPermission;

    var hasTrigger = collections
            ?.where((element) =>
                element.triggers != null && element.triggers!.isNotEmpty)
            .isNotEmpty ??
        false;
    Map<String, String>? identifierMapping;
    TriggerService? triggerService;
    PermissionHandlerService? permissionHandler;

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
      permissionHandler = PermissionHandlerService.create(
          defaultPermission: defaultPermission,
          collections: collections,
          defaultRules: defaultPermissionsByType);
    }

    if (hasTrigger) {
      triggerService = TriggerService.create(collections: collections);
    }

    DataAccess<L> acc;

    if (collections?.isEmpty ?? true) {
      acc = _DataAccessEmpty<L>(implementation, identifierMapping);
    } else if (triggerService != null && permissionHandler == null) {
      acc = _DataAccessWithOnlyTrigger<L>(
          implementation, triggerService, identifierMapping);
    } else if (triggerService == null && permissionHandler != null) {
      acc = _DataAccessWithPermission<L>(
          implementation, permissionHandler, identifierMapping);
    } else {
      acc = _DataAccessWithTriggerAndPermission<L>(implementation,
          triggerService!, permissionHandler!, identifierMapping);
    }

    QueryLanguageBinding().initDelegate(CommonLanguageDelegate());

    return acc;
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
  static DataAccess of(BuildContext context) => context.dataAccess;

  final QueryLanguageBinding _queryLanguageBinding = QueryLanguageBinding();

  ///
  AccessEvent<L> buildAccess(AccessEvent builder) {
    var res = _queryLanguageBinding.convertTo<L>(builder.access);
    return AccessEvent<L>(access: res, request: builder.request);
  }

  ///
  DataAccessImplementation implementation;

  ///
  PermissionHandlerService? permissionHandler;

  ///
  TriggerService? triggerService;

  FutureOr<T> _operation<T extends DbResult>(
      AccessEvent event, FutureOr<T> Function(Access access) interoperation);

  ///
  FutureOr<DbResult> any(AccessEvent access) {
    switch (access.access.type) {
      case AccessType.read:
        return _operation(access, _read);
      case AccessType.readMultiple:
        return _operation(access, _readList);
      case AccessType.create:
        return _operation(access, _create);
      case AccessType.update:
        return _operation(access, _update);
      case AccessType.exists:
        return _operation(access, _exists);
      case AccessType.listen:
        throw UnimplementedError();
      case AccessType.delete:
        return _operation(access, _delete);
      case AccessType.count:
        return _operation(access, _count);
      case AccessType.aggregation:
        return _operation(access, _aggregation);
    }
  }

  ///
  FutureOr<ReadDbResult> read(AccessEvent<L> access) =>
      _operation<ReadDbResult>(access, _read);

  ///
  FutureOr<ReadListResult> readList(AccessEvent<L> access) =>
      _operation<ReadListResult>(access, _readList);

  ///
  FutureOr<ReadListResult> aggregation(AccessEvent<L> access) =>
      _operation<ReadListResult>(access, _aggregation);

  ///
  FutureOr<DbResult<bool>> exists(AccessEvent<L> access) =>
      _operation<DbResult<bool>>(access, _exists);

  ///
  FutureOr<DeleteDbResult> delete(AccessEvent<L> access) =>
      _operation<DeleteDbResult>(access, _delete);

  ///
  FutureOr<UpdateDbResult> update(AccessEvent<L> access) =>
      _operation<UpdateDbResult>(access, _update);

  ///
  FutureOr<CreateDbResult> create(AccessEvent<L> access) =>
      _operation<CreateDbResult>(access, _create);

  ///
  FutureOr<DbResult<int>> count(AccessEvent<L> access) =>
      _operation<DbResult<int>>(access, _count);

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
  FutureOr<bool> init([bool inInterface = true]) => _initDb();

  ///
  Map<String, dynamic> toMap() => {
        'implementation': implementation.runtimeType,
        'data_access': runtimeType,
        'wrapper': (context as Binding).key.key
      };
}

class _DataAccessWithTriggerAndPermission<L extends AccessLanguage>
    extends DataAccess<L> {
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
  FutureOr<T> _operation<T extends DbResult>(AccessEvent builder,
      FutureOr<T> Function(Access<L> acc) interoperation) async {
    var e = buildAccess(builder);
    if (await permissionHandler!.check(e)) {
      return triggerService!.triggerAndReturn(e, interoperation);
    } else {
      throw ForbiddenUnauthorizedException();
    }
  }
}

class _DataAccessWithOnlyTrigger<L extends AccessLanguage>
    extends DataAccess<L> {
  _DataAccessWithOnlyTrigger(DataAccessImplementation implementation,
      TriggerService triggerService, Map<String, String>? identifierMapping)
      : super._(implementation,
            triggerService: triggerService,
            identifierMapping: identifierMapping);

  @override
  FutureOr<T> _operation<T extends DbResult>(AccessEvent builder,
      FutureOr<T> Function(Access<L> access) interoperation) {
    try {
      return triggerService!
          .triggerAndReturn(buildAccess(builder), interoperation);
    } on Exception {
      rethrow;
    }
  }
}

class _DataAccessEmpty<L extends AccessLanguage> extends DataAccess<L> {
  _DataAccessEmpty(DataAccessImplementation implementation,
      Map<String, String>? identifierMapping)
      : super._(implementation, identifierMapping: identifierMapping);

  @override
  FutureOr<T> _operation<T extends DbResult>(AccessEvent access,
          FutureOr<T> Function(Access<L> acc) interoperation) =>
      interoperation(buildAccess(access).access);
}

class _DataAccessWithPermission<L extends AccessLanguage>
    extends DataAccess<L> {
  _DataAccessWithPermission(
      DataAccessImplementation implementation,
      PermissionHandlerService permissionHandler,
      Map<String, String>? identifierMapping)
      : super._(implementation,
            permissionHandler: permissionHandler,
            identifierMapping: identifierMapping);

  @override
  FutureOr<T> _operation<T extends DbResult>(AccessEvent builder,
      FutureOr<T> Function(Access<L> access) interoperation) async {
    try {
      var e = buildAccess(builder);
      if (await permissionHandler!.check(e)) {
        return interoperation(e.access);
      } else {
        throw ForbiddenUnauthorizedException()..payload = e.toMap(false);
      }
    } on Exception {
      rethrow;
    }
  }
}

///
abstract class DataAccessImplementation<L extends AccessLanguage> {
  ///
  FutureOr<bool> init();

  ///
  FutureOr<DbResult> any(AccessEvent<L> event) {
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
  FutureOr<ReadDbResult> read(Access<L> access);

  ///
  FutureOr<ReadListResult> readList(Access<L> access);

  ///
  FutureOr<ReadListResult> aggregation(Access<L> access);

  ///
  FutureOr<DeleteDbResult> delete(Access<L> access);

  ///
  FutureOr<UpdateDbResult> update(Access<L> access);

  ///
  FutureOr<CreateDbResult> create(Access<L> access);

  ///
  FutureOr<BoolDbResult> exists(Access<L> access);

  ///
  FutureOr<CountDbResult> count(Access<L> access);

  ///
  BuildContext get context => dataAccess.context;

  ///
  late final DataAccess<L> dataAccess;
}

///
typedef BoolDbResult = DbResult<bool>;

///
typedef CountDbResult = DbResult<int>;

///
typedef ReadDbResult = DbResult<Map<String, dynamic>>;

///
typedef ArrayDbResult<T> = DbResult<List<T>?>;

///
typedef ReadListResult = ArrayDbResult<Map<String, dynamic>>;

///
typedef AggregationResult = ArrayDbResult<Map<String, dynamic>>;

/// Database Operation Result
class DbResult<T> {
  ///
  DbResult({required this.data, this.statusCode, this.headers});

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
class SimpleCacheDataAccess extends DataAccessImplementation<CommonLanguage> {
  ///
  SimpleCacheDataAccess();

  ///
  final Map<String, Map<String, Map<String, dynamic>>> data = {};

  @override
  Future<bool> init([bool inInterface = true]) async => true;

  @override
  FutureOr<CreateDbResult> create(Access<CommonLanguage> access) =>
      CreateDbResult(identifier: '1111');

  @override
  FutureOr<DeleteDbResult> delete(Access<CommonLanguage> access) {
    throw UnimplementedError();
    // if (access.identifier == null) {
    //   throw BadRequests();
    // }
    // if (data[access.collection]?[access.identifier!] == null) {
    //   return DeleteDbResult(exists: false);
    // } else {
    //   data[access.collection]!.remove(access.identifier);
    //   return DeleteDbResult(exists: true);
    // }
  }

  @override
  Future<ReadDbResult> read(Access<CommonLanguage> access) async {
    throw UnimplementedError();
    // if (access.identifier == null) {
    //   throw BadRequests();
    // }
    // var d = data[access.collection]?[access.identifier];
    //
    // if (d == null) throw NotFoundException();
    // return ReadDbResult(data: Map<String, dynamic>.from(d));
  }

  @override
  FutureOr<ReadListResult> readList(covariant CommonAccess access) {
    var q = access.query as CommonQuery?;

    if (q?.filter != null) {
      Logger.of(context).warn(context, 'query_not_supported',
          title: 'Query selector '
              'not supported with SimpleCacheDataAccess , so its skipped');
    }

    if (q?.sortExpression != null) {
      Logger.of(context).warn(context, 'sort_not_supported',
          title: 'Query sort '
              'not supported with SimpleCacheDataAccess , so its skipped');
    }
    if (access.query?.fields != null) {
      Logger.of(context).warn(context, 'fields_not_supported',
          title: 'Query fields '
              'not supported with SimpleCacheDataAccess , so its skipped');
    }
    var l = q?.limit ?? 200;
    var s = q?.offset ?? 0;

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
  FutureOr<UpdateDbResult> update(Access<CommonLanguage> access) {
    throw UnimplementedError();
    // if (access.update == null) {
    //   throw BadRequests();
    // }
    // if (access.identifier == null) {
    //   throw BadRequests();
    // }
    // data[access.collection]?[access.identifier]
    // ?.addAll(access.update!.toMap());
    // return UpdateDbResult(data: null);
  }

  @override
  FutureOr<DbResult<int>> count(Access<CommonLanguage> access) {
    if (access.query != null) {
      Logger.of(context).warn(context, 'query_not_supported',
          title: 'Query '
              'not supported with SimpleCacheDataAccess , so its skipped');
    }
    return DbResult<int>(data: data[access.collection]?.length ?? 0);
  }

  @override
  FutureOr<DbResult<bool>> exists(Access<CommonLanguage> access) {
    throw UnimplementedError();
    // // TODO: implement exists
    // if (access.query != null) {
    //   Logger.of(context).warn(context, "query_not_supported",
    //       title: "Query "
    //           "not supported with SimpleCacheDataAccess , so its skipped");
    // }
    //
    // if (access.identifier == null) {
    //   throw BadRequests();
    // }
    //
    // return DbResult<bool>(
    //     data: data[access.collection]?[access.identifier!] != null);
  }

  @override
  FutureOr<ReadListResult> aggregation(Access<CommonLanguage> access) {
    throw UnimplementedError(
        'Aggregation not supported with Simple(Cache)DataAccess');
  }
}

///
// class StoreDelegate<T extends Identifier> {
//   ///
//   StoreDelegate(
//       {required this.collection,
//       DataAccess? customAccess,
//       required this.toMap,
//       required this.fromMap})
//       : _access = customAccess;
//
//   ///
//   DataAccess get access => _access!;
//
//   ///
//   void attach(BuildContext context) {
//     _access ??= DataAccess.of(context);
//   }
//
//   ///
//   Future<T> read(String id) async {
//     return fromMap(
//         (await access.read(Read(collection:
//         collection, identifier: id))).data);
//   }
//
//   ///
//   Future<void> write(T instance) async {
//     await access.create(Create(collection:
//     collection, data: toMap(instance)));
//   }
//
//   ///
//   Future<void> delete(String identifier) async {
//     await access.delete(Delete(collection:
//     collection, identifier: identifier));
//   }
//
//   DataAccess? _access;
//
//   ///
//   String collection;
//
//   ///
//   Map<String, dynamic> Function(T instance) toMap;
//
//   ///
//   T Function(Map<String, dynamic> map) fromMap;
// }

///
class SimpleDataAccess extends SimpleCacheDataAccess {
  ///
  SimpleDataAccess(this.directory)
      : assert(directory.endsWith(Platform.pathSeparator) ||
            directory.endsWith('/'));

  ///
  String directory;

  @override
  Future<bool> init([bool inInterface = true]) async {
    var docs = await Directory(directory)
        .list()
        .where((event) => event.path.endsWith('.json'))
        .toList();

    var colsFtrs =
        docs.map((e) async => json.decode(await File(e.path).readAsString()));
    var cols = await Future.wait(colsFtrs);
    var i = 0;
    while (i < cols.length) {
      data[docs[i].path.split('/').last.replaceAll('.json', '')] =
          (cols[i] as Map).cast<String, Map<String, dynamic>>();
      i++;
    }
    return true;
  }

  ///
  Future<void> saveCollection(String collection) async {
    var f = File('$directory$collection.json');
    if (!(await f.exists())) {
      await f.create();
    }
    await f.writeAsString(json.encode(data[collection]));
  }

  @override
  FutureOr<CreateDbResult> create(Access<CommonLanguage> access) async {
    var res = await super.create(access);

    await saveCollection(access.collection);

    return res;
  }

  @override
  FutureOr<UpdateDbResult> update(Access<CommonLanguage> access) async {
    var res = await super.update(access);

    await saveCollection(access.collection);

    return res;
  }

  @override
  FutureOr<DeleteDbResult> delete(Access<CommonLanguage> access) async {
    var res = await super.delete(access);

    await saveCollection(access.collection);

    return res;
  }
}
