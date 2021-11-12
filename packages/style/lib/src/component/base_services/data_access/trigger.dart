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

///On Document Create Function
typedef OnEvent = Future<void> Function(AccessEvent event);

///
class TriggerService {
  // ignore_for_file: lines_longer_than_80_chars
  ///
  TriggerService.create({bool? streamSupport, List<DbCollection>? collections})
      : /*streamSupport = streamSupport ?? false,*/
        _triggers = _getTriggers(collections);

  ///
  late DataAccess dataAccess;

  static HashMap<String, HashMap<TriggerType, List<Trigger>>> _getTriggers(
      List<DbCollection>? collections) {
    if (collections == null) {
      return HashMap.from({});
    }

    var _map = <String, HashMap<TriggerType, List<Trigger>>>{};

    for (var col in collections) {
      for (var trigger in col.triggers ?? <Trigger>[]) {
        _map[col.collectionName] ??= HashMap<TriggerType, List<Trigger>>.of({});
        _map[col.collectionName]![trigger.type] ??= <Trigger>[];
        _map[col.collectionName]![trigger.type]!.add(trigger);
      }
    }
    return HashMap.from(_map);
  }

  ///
/*  final bool streamSupport;*/

  ///
  final HashMap<String, HashMap<TriggerType, List<Trigger>>> _triggers;

  ///
  // final HashMap<StreamConsumer, Trigger> listeners = HashMap.from({});

  ///
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

    var _trs = <Trigger>[
      ...?_triggers[event.access.collection]?[type],
      ...?_triggers[event.access.collection]?[TriggerType.onWrite]
    ];

    if (_trs.isEmpty) return interoperation();

    var _befNeed = _trs.where((element) => element._beforeNeed).isNotEmpty;
    var _afterNeed = _trs.where((element) => element._afterNeed).isNotEmpty;

    switch (type) {
      case TriggerType.onCreate:
        var _inter = await interoperation();
        if (_inter.success) {
          for (var tr in _trs) {
            tr.onEvent(event);
          }
        }
        return _inter;
      case TriggerType.onUpdate:
        if (_befNeed) {
          event.before ??= (await dataAccess._read(event.access)).data;
        }

        ///
        var _inter = (await interoperation()) as UpdateDbResult;
        if (_inter.success) {
          if (_afterNeed && _inter.newData == null) {
            event.after ??= (await dataAccess._read(event.access)).data;
          }
          for (var tr in _trs) {
            tr.onEvent(event);
          }
        } else {
          return _inter as T;
        }

        return _inter as T;
      case TriggerType.onDelete:
        if (_befNeed) {
          event.before ??= (await dataAccess._read(event.access)).data;
        }
        var _inter = await interoperation();
        if (_inter.success) {
          for (var tr in _trs) {
            tr.onEvent(event);
          }
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
//
// ///
// @immutable
// class StreamListener {
//   ///
//   StreamListener(this.consumer, {String? customId})
//       : identifier = customId ?? getRandomId(30);
//
//   ///
//   final String identifier;
//
//   ///
//   final StreamController consumer;
//
//   @override
//   bool operator ==(Object other) {
//     return other is StreamListener && other.identifier == identifier;
//   }
//
//   @override
//   int get hashCode => identifier.hashCode;
//
//   ///
//   void close() {
//
//   }
// }
