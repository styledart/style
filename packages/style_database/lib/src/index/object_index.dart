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

part of '../style_database_base.dart';

/// Not sortable objects
///
/// Not sorting anyway.
///
abstract class ObjectIndex<V extends Object> extends Indexer<V> {
  ///
  ObjectIndex(String key, {required bool unique, required Database database})
      : super(key, database: database, unique: unique);

  @override
  void indexObject(String id, V value) {}

  @override
  bool _isMatch(String id, MatchExpression<V> expression) =>
      expression.compareTo(valueStorage.getValue(id));

  @override
  Iterator<String> getIterator(MatchExpression<V> matchExpression) {
    throw UnimplementedError();
  }
}
