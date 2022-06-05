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

part of '../../style_base.dart';

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
      : key = key ?? _randomKey.generateString();

  ///
  factory Trigger.onCreate({required OnEvent onEvent, String? key}) =>
      Trigger._(TriggerType.onCreate, onEvent, false, false, key);

  ///
  factory Trigger.onDelete(
          {required OnEvent onEvent, bool? afterNeed, String? key}) =>
      Trigger._(TriggerType.onDelete, onEvent, false, afterNeed ?? false, key);

  ///
  factory Trigger.onUpdate(
          {required OnEvent onEvent,
          bool? beforeNeed,
          bool? afterNeed,
          String? key}) =>
      Trigger._(TriggerType.onUpdate, onEvent, beforeNeed ?? false,
          afterNeed ?? false, key);

  ///
  factory Trigger.onWrite(
          {required OnEvent onEvent,
          bool? beforeNeed,
          bool? afterNeed,
          String? key}) =>
      Trigger._(TriggerType.onWrite, onEvent, beforeNeed ?? false,
          afterNeed ?? false, key);

  ///
  TriggerType type;

  ///
  OnEvent onEvent;

  ///
  String key;

  final bool _beforeNeed;
  final bool _afterNeed;
}
