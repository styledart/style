/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE,
 *    Version 3 (the "License");
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

part of '../style_database_base.dart';

/// Multiple
class SortedIndex<T extends Comparable> extends Indexer<T> {
  ///
  SortedIndex(String key,
      {required Database database,
      required this.ascending,
      required bool unique})
      : super(key, unique: unique, database: database);

  ///
  final bool ascending;

  ///
  final BinaryTree<T> _values = BinaryTree<T>();

  @override
  void indexObject(String id, T value) {
    valueStorage.add(id, value);
    _values.insert(value);
  }

  @override
  Iterator<String> getIterator(MatchExpression<T> matchExpression,
          [MatchExpression<T>? bound]) =>
      valueStorage is UniqueValueStorage
          ? _IDValueIterator(
              this,
              _values.iteratorFrom(
                matchExpression.queryValue,
                greaterThan: true,
                equal: false,
                /*bound: bound != null
                  ? Bound(element: bound.queryValue, equal: false)
                  : null*/
              ))
          : _DuplicateIDValueIterator(
              this,
              _values.iteratorFrom(
                matchExpression.queryValue,
                greaterThan: true,
                equal: false,
                /*bound: bound != null
                  ? Bound(element: bound.queryValue, equal: false)
                  : null*/
              ));
}

class _IDValueIterator<S extends Comparable> extends Iterator<String> {
  _IDValueIterator(this.index, this.iterator);

  ///
  SortedIndex<S> index;

  Iterator<S> iterator;

  @override
  String get current => _current!;

  String? _current;

  @override
  bool moveNext() {
    var n = iterator.moveNext();
    if (n) {
      _current = (index.valueStorage.getID(iterator.current) as String?);
      if (_current == null) {
        throw Exception();
      } else {
        return true;
      }
    } else {
      return false;
    }
  }
}

class _DuplicateIDValueIterator<S extends Comparable> extends Iterator<String> {
  _DuplicateIDValueIterator(this.index, this.iterator);

  ///
  SortedIndex<S> index;

  Iterator<S> iterator;

  @override
  String get current => _current!;

  String? _current;

  Iterator<String>? _currentIterator;

  @override
  bool moveNext() {
    while (true) {
      if (_currentIterator == null) {
        var n = iterator.moveNext();
        if (n) {
          _currentIterator =
              (index.valueStorage.getID(iterator.current) as List<String>)
                  .iterator;
        } else {
          return false;
        }
      }

      var nn = _currentIterator!.moveNext();

      if (nn) {
        _current = _currentIterator!.current;
        return true;
      } else {
        _currentIterator = null;
        continue;
      }
    }
  }
}
