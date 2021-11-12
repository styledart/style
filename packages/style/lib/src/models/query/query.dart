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

///
class AccessEvent {
  ///
  AccessEvent(
      {required this.access, required this.request, this.errors, this.context})
      : createTime = DateTime.now(),
        type = _getDbOpType(access.type);

  // ///
  // factory AccessEvent.fromMap(Map<String, dynamic> map,
  // Request request) {
  //   return AccessEvent(access: Access.fromMap(map["access"]),
  //   request: request);
  // }

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
  Access access;

  ///
  AccessToken? get token => request.token;

  ///
  DbOperationType type;

  ///
  Request request;

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
        "data_access": context?.dataAccess.toMap() ?? "unknown",
        "type": type.index,
        "create": createTime.millisecondsSinceEpoch,
        "request": request.toMap(),
        if (includeBeforeAfter) "before": before,
        if (includeBeforeAfter) "after": after,
        "access": access.toMap(),
        "errors": errors
      };
}
