/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE, Version 3 (the "License");
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

///On Document Create Function
typedef OnEvent = Future<void> Function(AccessEvent event);

///
class TriggerService {
  // ignore_for_file: lines_longer_than_80_chars
  ///
  TriggerService.create({List<DbCollection>? collections})
      : /*streamSupport = streamSupport ?? false,*/
        _triggers = _getTriggers(collections);

  ///
  late DataAccess dataAccess;

  static HashMap<String, HashMap<TriggerType, List<Trigger>>> _getTriggers(
      List<DbCollection>? collections) {
    if (collections == null) {
      return HashMap.from({});
    }

    var map = <String, HashMap<TriggerType, List<Trigger>>>{};

    for (var col in collections) {
      for (var trigger in col.triggers ?? <Trigger>[]) {
        map[col.collectionName] ??= HashMap<TriggerType, List<Trigger>>.of({});
        map[col.collectionName]![trigger.type] ??= <Trigger>[];
        map[col.collectionName]![trigger.type]!.add(trigger);
      }
    }
    return HashMap.from(map);
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
  FutureOr<T> triggerAndReturn<T extends DbResult, L extends AccessLanguage>(
      AccessEvent<L> event,
      FutureOr<T> Function(Access<L> acc) interoperation) async {
    var type = _getTriggerType(event.type);
    if (type == TriggerType.non) return interoperation(event.access);

    var trs = <Trigger>[
      ...?_triggers[event.access.collection]?[type],
      ...?_triggers[event.access.collection]?[TriggerType.onWrite]
    ];

    if (trs.isEmpty) return interoperation(event.access);

    var befNeed = trs.where((element) => element._beforeNeed).isNotEmpty;
    var afterNeed = trs.where((element) => element._afterNeed).isNotEmpty;

    switch (type) {
      case TriggerType.onCreate:
        var inter = await interoperation(event.access);
        for (var tr in trs) {
          await tr.onEvent(event);
        }
        return inter;
      case TriggerType.onUpdate:
        if (befNeed) {
          event.before ??= (await dataAccess._read(event.access)).data;
        }

        ///
        var inter = (await interoperation(event.access)) as UpdateDbResult;
        if (afterNeed && inter.newData == null) {
          event.after ??= (await dataAccess._read(event.access)).data;
        }
        for (var tr in trs) {
          await tr.onEvent(event);
        }

        return inter as T;
      case TriggerType.onDelete:
        if (befNeed) {
          event.before ??= (await dataAccess._read(event.access)).data;
        }
        var inter = await interoperation(event.access);
        for (var tr in trs) {
          await tr.onEvent(event);
        }
        return inter;
      case TriggerType.onWrite:
        throw UnsupportedError(
            'Operation base trigger type can not be onWrite');
      case TriggerType.non:
        throw UnimplementedError();
    }
  }
}
