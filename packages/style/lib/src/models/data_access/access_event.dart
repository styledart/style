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

part of '../../style_base.dart';

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

// class AccessBuilder {
//   ///
//   AccessBuilder(
//       {this.request , required this.access, this.context});
//
//   ///
//   Request? request;
//
//   ///
//   BuildContext? context;
//
//   ///
//   Access access;
// }

///
class AccessEvent<T extends AccessLanguage> {
  ///
  AccessEvent(
      {required this.access, required this.request, this.errors, this.context})
      : createTime = DateTime.now(),
        type = _getDbOpType(access.type);

  ///
  static DbOperationType _getDbOpType(AccessType type) {
    switch (type) {
      case AccessType.read:
        return DbOperationType.read;
      case AccessType.readMultiple:
        return DbOperationType.read;
      case AccessType.create:
        return DbOperationType.create;
      case AccessType.update:
        return DbOperationType.update;
      case AccessType.exists:
        return DbOperationType.read;
      case AccessType.listen:
        return DbOperationType.read;
      case AccessType.delete:
        return DbOperationType.delete;
      case AccessType.count:
        return DbOperationType.read;
      case AccessType.aggregation:
        return DbOperationType.read;
    }
  }

  ///
  Access<T> access;

  ///
  AccessToken? get token => request?.token;

  ///
  DbOperationType type;

  ///
  Request? request;

  ///
  final DateTime createTime;

  ///
  Map<String, dynamic>? before, after;

  ///
  List<MapEntry<String, dynamic>>? errors;

  ///
  BuildContext? context;

  // ignore_for_file: avoid_positional_boolean_parameters
  ///
  Map<String, dynamic> toMap([bool includeBeforeAfter = true]) => {
        'data_access': context?.dataAccess.toMap() ?? 'unknown',
        'type': type.index,
        'create': createTime.millisecondsSinceEpoch,
        'request': request?.toMap(),
        if (includeBeforeAfter) 'before': before,
        if (includeBeforeAfter) 'after': after,
        'access': access.toMap(),
        'errors': errors
      };
}

///
class Read<L extends AccessLanguage> extends AccessEvent<L> {
  ///
  Read(
      {Request? request,
      required String collection,
      required Query<L> query,
      AccessToken? customToken})
      : super(
            request: request?..token = customToken,
            access: Access<L>(
                type: AccessType.read, collection: collection, query: query));
}

///
class ReadMultiple<L extends AccessLanguage> extends AccessEvent<L> {
  ///
  ReadMultiple(
      {Request? request,
      required String collection,
      Query<L>? query,
      AccessToken? customToken})
      : super(
            request: request?..token = customToken,
            access: Access<L>(
                type: AccessType.readMultiple,
                collection: collection,
                query: query));
}

///
class Create<L extends AccessLanguage> extends AccessEvent<L> {
  ///
  Create(
      {Request? request,
      required String collection,
      required CreateData<L> data,
      AccessToken? customToken})
      : super(
            request: request?..token = customToken,
            access: Access(
                type: AccessType.create, collection: collection, create: data));
}

///
class Update<L extends AccessLanguage> extends AccessEvent<L> {
  ///
  Update(
      {Request? request,
      required String collection,
      Query<L>? query,
      String? identifier,
      required UpdateData<L> data,
      AccessToken? customToken})
      : assert(identifier != null || query != null),
        super(
            request: request?..token = customToken,
            access: Access(
                type: AccessType.update, collection: collection, update: data));
}

///
class Delete<L extends AccessLanguage> extends AccessEvent<L> {
  ///
  Delete(
      {Request? request,
      required String collection,
      required Query<L> query,
      AccessToken? customToken})
      : super(
            request: request?..token = customToken,
            access: Access<L>(
                type: AccessType.delete, collection: collection, query: query));
}

///
class Count<L extends AccessLanguage> extends AccessEvent<L> {
  ///
  Count(
      {Request? request,
      required String collection,
      Query<L>? query,
      AccessToken? customToken})
      : super(
          request: request?..token = customToken,
          access: Access(
              type: AccessType.count, collection: collection, query: query),
        );
}

///
class Exists<L extends AccessLanguage> extends AccessEvent<L> {
  ///
  Exists(
      {Request? request,
      required String collection,
      required Query<L> query,
      AccessToken? customToken})
      : super(
            request: request?..token = customToken,
            access: Access<L>(
                type: AccessType.exists, collection: collection, query: query));
}
