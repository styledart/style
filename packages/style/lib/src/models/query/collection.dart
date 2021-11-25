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
class DbCollection {
  ///
  DbCollection(
    this.collectionName, {
    JsonSchema? createSchema,
    JsonSchema? updateSchema,
    this.triggers,
    PermissionHandler? permissionHandler,
    this.identifier,
    JsonSchema? resourceSchemaOnUpdate,
  })  : permissionHandler = _getHandler(
            permissionHandler: permissionHandler,
            createSchema: createSchema,
            resourceSchemaOnUpdate: resourceSchemaOnUpdate,
            updateSchema: updateSchema),
        hasSchema = resourceSchemaOnUpdate != null ||
            createSchema != null ||
            updateSchema != null;

  static PermissionHandler? _getHandler({
    required JsonSchema? createSchema,
    required JsonSchema? updateSchema,
    required PermissionHandler? permissionHandler,
    required JsonSchema? resourceSchemaOnUpdate,
  }) {
    var basePer = permissionHandler;
    var _hasSchema = createSchema != null ||
        updateSchema != null ||
        resourceSchemaOnUpdate != null;
    PermissionHandler? schema;
    if (_hasSchema) {
      schema = PermissionHandler._schema(
          updateSchema: updateSchema,
          createScheme: createSchema,
          onUpdateResource: resourceSchemaOnUpdate);
    }
    if (basePer == null && schema == null) return null;
    return PermissionHandler.merge(
        [if (basePer != null) basePer, if (schema != null) schema]);
  }

  ///
  final bool hasSchema;

  ///
  final String collectionName;

  ///
  final String? identifier;

  ///
  final List<Trigger>? triggers;

  ///
  final PermissionHandler? permissionHandler;
}

///
typedef PermissionCheckerCallback = FutureOr<bool> Function(AccessEvent event);

///
class PermissionHandler {
  ///
  PermissionHandler.custom(
      {required PermissionCheckerCallback callback, this.beforeNeed = false}) {
    checker = (_) {
      return callback(_);
    };
  }

  static FutureOr<bool> _validateCreate(
      FutureOr<JsonSchema> create, AccessEvent a) async {
    if (a.type != DbOperationType.create) {
      return true;
    }
    var validator = StyleValidator(await create);
    var valid = validator.validate(a.access.data);
    if (!valid) {
      a.errors = validator.errorObjects.map((e) => e.toMapEntry()).toList();
    }
    return valid;
  }

  static FutureOr<bool> _validateUpdate(
      FutureOr<JsonSchema> update, AccessEvent a) async {
    if (a.type != DbOperationType.update) {
      return true;
    }

    var validator = StyleValidator(await update);
    var valid = validator.validate(a.access.data);
    if (!valid) {
      a.errors = validator.errorObjects.map((e) => e.toMapEntry()).toList();
    }

    return valid;
  }

  static FutureOr<bool> _validateOnUpdateResource(
      FutureOr<JsonSchema> update, AccessEvent a,
      {bool allowResourceIsNull = false}) async {
    if (a.type != DbOperationType.update) {
      return true;
    }

    if (a.before == null) {
      return allowResourceIsNull;
    }

    var validator = StyleValidator(await update);
    var valid = validator.validate(a.before);
    if (!valid) {
      a.errors = validator.errorObjects.map((e) => e.toMapEntry()).toList();
    }
    return valid;
  }

  ///
  factory PermissionHandler.merge(List<PermissionHandler> handlers) {
    return PermissionHandler.custom(
        callback: (a) async {
          var checkers = <Future<bool>>[];
          for (var handler in handlers) {
            checkers.add(Future.value(handler.checker(a)));
          }
          return (await Future.wait(checkers))
              .where((element) => element)
              .isNotEmpty;
        },
        beforeNeed: handlers.where((element) => element.beforeNeed).isNotEmpty);
  }

  ///
  PermissionHandler._schema(
      {FutureOr<JsonSchema>? createScheme,
      FutureOr<JsonSchema>? updateSchema,
      FutureOr<JsonSchema>? onUpdateResource})
      : beforeNeed = onUpdateResource != null {
    var call = <PermissionCheckerCallback>[];

    if (createScheme != null) {
      call.add((a) async {
        return _validateCreate(createScheme, a);
      });
    }

    if (updateSchema != null) {
      call.add((a) async {
        return _validateUpdate(updateSchema, a);
      });
    }

    if (onUpdateResource != null) {
      call.add((a) async {
        return _validateOnUpdateResource(onUpdateResource, a);
      });
    }

    checker = (a) async {
      var t = false;
      for (var c in call) {
        t = await c(a);
        if (!t) return false;
      }
      return t;
    };
  }

  ///
  PermissionHandler.generatedByType(
      {PermissionCheckerCallback? read,
      PermissionCheckerCallback? update,
      PermissionCheckerCallback? delete,
      PermissionCheckerCallback? create,
      PermissionCheckerCallback? write,
      required bool defaultPermission,
      this.beforeNeed = false})
      : assert(write == null ||
            (update == null && delete == null && create == null)) {
    var defaultsMap = {
      if (write != null) ...{
        DbOperationType.create: write,
        DbOperationType.update: write,
        DbOperationType.delete: write,
      },
      if (read != null) DbOperationType.read: read,
      if (update != null) DbOperationType.update: update,
      if (create != null) DbOperationType.create: create,
      if (delete != null) DbOperationType.delete: delete
    };

    checker = (_) {
      return (defaultsMap[_.access.type]?.call(_)) ?? defaultPermission;
    };
    ;
  }

  ///
  PermissionHandler.static({
    bool? read,
    bool? update,
    bool? delete,
    bool? create,
    bool? write,
    required bool defaultPermission,
  })  : beforeNeed = false,
        assert(write == null ||
            (update == null && delete == null && create == null)) {
    var defaultsMap = {
      if (write != null) DbOperationType.create: write,
      if (write != null) DbOperationType.update: write,
      if (write != null) DbOperationType.delete: write,
      if (read != null) DbOperationType.read: read,
      if (update != null) DbOperationType.update: update,
      if (create != null) DbOperationType.create: create,
      if (delete != null) DbOperationType.delete: delete
    };

    checker = (_) {
      return defaultsMap[_.type] ?? defaultPermission;
    };
  }

  ///
  late final PermissionCheckerCallback checker;

  // ///
  // Map<String, dynamic>? createScheme;
  //
  // ///
  // Map<String, dynamic>? updateSchema;

  ///
  final bool beforeNeed;
}

///
enum TriggerType {
  ///
  onCreate,

  ///
  onUpdate,

  ///
  onDelete,

  ///
  onWrite,

  ///
  non,
}

///
class Trigger {
  ///
  Trigger._(
      this.type, this.onEvent, this._beforeNeed, this._afterNeed, String? key)
      : key = key ?? getRandomId(10);

  ///
  factory Trigger.onCreate({required OnEvent onEvent, String? key}) {
    return Trigger._(TriggerType.onCreate, onEvent, false, false, key);
  }

  ///
  factory Trigger.onDelete(
      {required OnEvent onEvent, bool? afterNeed, String? key}) {
    return Trigger._(
        TriggerType.onDelete, onEvent, false, afterNeed ?? false, key);
  }

  ///
  factory Trigger.onUpdate(
      {required OnEvent onEvent,
      bool? beforeNeed,
      bool? afterNeed,
      String? key}) {
    return Trigger._(TriggerType.onUpdate, onEvent, beforeNeed ?? false,
        afterNeed ?? false, key);
  }

  ///
  factory Trigger.onWrite(
      {required OnEvent onEvent,
      bool? beforeNeed,
      bool? afterNeed,
      String? key}) {
    return Trigger._(TriggerType.onWrite, onEvent, beforeNeed ?? false,
        afterNeed ?? false, key);
  }

  ///
  TriggerType type;

  ///
  OnEvent onEvent;

  ///
  String key;

  final bool _beforeNeed;
  final bool _afterNeed;
}
