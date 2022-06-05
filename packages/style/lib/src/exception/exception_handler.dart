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

part of '../style_base.dart';

///
class ExceptionHandler {
  ///
  ExceptionHandler(Map<Type, ExceptionEndpointCallingBinding> map)
      : _map = HashMap<Type, ExceptionEndpointCallingBinding>.from(map);

  final HashMap<Type, ExceptionEndpointCallingBinding> _map;

  ///
  ExceptionHandler copyWith([Map<Type, ExceptionEndpointCallingBinding>? map]) {
    var n = ExceptionHandler(_map);
    if (map != null) {
      n._map.addAll(map);
    }
    return n;
  }

  ///
  ExceptionEndpointCallingBinding getBinding(Exception e)=> _map[e.runtimeType] ?? _findSuperTypes(e) ?? _map[Exception]!;

  ExceptionEndpointCallingBinding? _findSuperTypes<T extends Exception>(
      Exception e) {
    if (e is StyleException) {
      return _map[e.superType] ?? _map[StyleException];
    }
    return null;
  }
}
