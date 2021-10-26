/*
 * Copyright (c) 2021. This code was written by Mehmet Yaz.
 * Mehmet Yaz does not accept the problems that may arise due to these codes.
 */
part of '../../style_base.dart';

///
class DbCollection {
  ///
  DbCollection(this.collectionName, {this.triggers, this.permissionHandler});

  ///
  final String collectionName;

  ///
  final List<Trigger>? triggers;

  ///
  final PermissionHandler? permissionHandler;
}

///
typedef PermissionHandlerCallback = FutureOr<bool> Function(AccessEvent event);

///
typedef PermissionCheckerCallback = FutureOr<bool> Function(AccessEvent event);

///
class PermissionHandler {
  ///
  PermissionHandler.custom(PermissionCheckerCallback callback,
      {this.beforeNeed = false}) {
    checker = (_) async {
      return callback(_);
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

    checker = (_) async {
      return (defaultsMap[_.access.type]?.call(_)) ?? defaultPermission;
    };
  }

  ///
  PermissionHandler.static(
      {bool? read,
      bool? update,
      bool? delete,
      bool? create,
      bool? write,
      required bool defaultPermission})
      : beforeNeed = false,
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
  late final PermissionHandlerCallback checker;

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
  Trigger._(this.type, this.onEvent, this._beforeNeed, this._afterNeed);

  ///
  factory Trigger.onCreate({required OnEvent onEvent}) {
    return Trigger._(TriggerType.onCreate, onEvent, false, false);
  }

  ///
  factory Trigger.onDelete({required OnEvent onEvent, bool? afterNeed}) {
    return Trigger._(TriggerType.onDelete, onEvent, false, afterNeed ?? false);
  }

  ///
  factory Trigger.onUpdate(
      {required OnEvent onEvent, bool? beforeNeed, bool? afterNeed}) {
    return Trigger._(
        TriggerType.onUpdate, onEvent, beforeNeed ?? false, afterNeed ?? false);
  }


  ///
  factory Trigger.onWrite(
      {required OnEvent onEvent, bool? beforeNeed, bool? afterNeed}) {
    return Trigger._(
        TriggerType.onWrite, onEvent, beforeNeed ?? false, afterNeed ?? false);
  }


  ///
  TriggerType type;

  ///
  OnEvent onEvent;

  final bool _beforeNeed;
  final bool _afterNeed;
}
