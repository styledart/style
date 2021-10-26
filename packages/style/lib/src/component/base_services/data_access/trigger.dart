/*
 * Copyright (c) 2021. This code was written by Mehmet Yaz.
 * Mehmet Yaz does not accept the problems that may arise due to these codes.
 */
part of '../../../style_base.dart';

///On Document Create Function
typedef OnEvent = Future<void> Function(AccessEvent event);

///
class TriggerService {
  // ignore_for_file: lines_longer_than_80_chars
  ///
  TriggerService.create({bool? streamSupport, List<DbCollection>? collections})
      : streamSupport = streamSupport ?? false,
        _triggers = HashMap<String, HashMap<TriggerType, Trigger>>.from(collections
                ?.where((element) =>
                    element.triggers != null && element.triggers!.isNotEmpty)
                .toList()
                .asMap()
                .map<String, HashMap<TriggerType, Trigger>>((key, value) =>
                    MapEntry(
                        value.collectionName,
                        HashMap<TriggerType, Trigger>.from(value.triggers!
                            .asMap()
                            .map<TriggerType, Trigger>(
                                (k, v) => MapEntry(v.type, v))))) ??
            {});

  ///
  late DataAccess dataAccess;

  ///
  final bool streamSupport;

  ///
  final HashMap<String, HashMap<TriggerType, Trigger>> _triggers;

  static TriggerType _getTriggerType(DbOperationType type) {
    switch (type) {
      case DbOperationType.update:
        return TriggerType.onUpdate;

      case DbOperationType.delete:
        return TriggerType.onDelete;
      case DbOperationType.read:
        return TriggerType.non;
      case DbOperationType.create:
        return TriggerType.onCreate;
    }
  }

  ///Trigger
  FutureOr<T> triggerAndReturn<T extends DbResult>(
      AccessEvent event, FutureOr<T> Function() interoperation) async {
    var type = _getTriggerType(event.type);
    if (type == TriggerType.non) return interoperation();
    var tr = _triggers[event.access.collection]?[type] ??
        _triggers[event.access.collection]?[TriggerType.onWrite];

    if (tr == null) return interoperation();

    switch (type) {
      case TriggerType.onCreate:
        var _inter = await interoperation();
        if (_inter.success) {
          tr.onEvent(event);
        }
        return _inter;
      case TriggerType.onUpdate:
        if (tr._beforeNeed) {
          event.before ??= (await dataAccess._read(event.access)).data;
        }

        ///
        var _inter = (await interoperation()) as UpdateDbResult;
        if (_inter.success) {
          if (tr._afterNeed && _inter.newData == null) {
            event.after ??= (await dataAccess._read(event.access)).data;
          }
          tr.onEvent(event);
        } else {
          return _inter as T;
        }

        return _inter as T;
      case TriggerType.onDelete:
        if (tr._beforeNeed) {
          event.before ??= (await dataAccess._read(event.access)).data;
        }
        var _inter = await interoperation();
        if (_inter.success) {
          tr.onEvent(event);
        }
        return _inter;
      case TriggerType.onWrite:
        throw UnsupportedError(
            "Operation base trigger type can not be onWrite");
      case TriggerType.non:
        throw UnimplementedError();
    }

  }
}
