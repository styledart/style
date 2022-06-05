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

///
abstract class Indexer<V extends Object> {
  ///
  Indexer(this.key, {required bool unique, required this.database})
      : valueStorage = unique
            ? UniqueValueStorage<V>(key: key)
            : MultipleValueStorage<V>(key: key) as IndexValueStorage;

  ///
  IndexValueStorage valueStorage;

  ///
  String key;

  ///
  Database database;

  ///
  Iterator<String> getIterator(MatchExpression<V> matchExpression);

  bool _isMatch(String id, MatchExpression<V> expression) =>
      expression.compareTo(valueStorage.getValue(id));

  ///
  void indexObject(String id, V value);
}

///
abstract class IndexMatch extends Iterator<String> {
  ///
  IndexMatch();

  ///
  bool isMatch(String id);
}

/// Non indexes field match
/// Scan match work with ID index.
///
/// moveNext give next id.
///
class ScanMatch extends IndexMatch {
  ScanMatch(this.storage, this.expression);

  ///
  Storage storage;

  MatchExpression expression;

  Iterator<String>? _iterator;

  ///
  String? _current;

  @override
  String get current => _current!;

  @override
  bool isMatch(String id) {
    throw UnimplementedError();
  }

  @override
  bool moveNext() {
    _iterator ??= storage.iterator;

    var n = _iterator!.moveNext();

    if (n) {
      _current = _iterator!.current;
      return true;
    } else {
      return false;
    }
  }
}

/// Sorted expression match
///
/// Örneğin:
///
/// {
///   and : [
///     [a , "==" , "b"],
///     [c , "==" , "d"]
///   ]
/// }
///
/// [a , "==" , "b"] bu ifade bir expression match'dir.
///
/// Bu ifade sıralı olarak  a == b olan dosyaları döndürür.
///
/// ikinci ifadeye ise compound bakar. ve c == d 'mi sorgular.
///
class ExpressionIndexMatch<T extends Comparable> extends IndexMatch {
  ///
  ExpressionIndexMatch(this.indexer, this.expression, {this.boundExpression});

  ///
  Iterator<String>? iterator;

  ///
  SortedIndex<T> indexer;

  ///
  MatchExpression<T> expression;

  ///
  MatchExpression<T>? boundExpression;

  ///
  String? _current;

  @override
  String get current => _current!;

  @override
  bool moveNext() {
    if (iterator == null) {
      iterator = indexer.getIterator(expression, boundExpression);
      if (iterator is Iterator<Iterable<String>>) {
        iterator = NestedIterator<String>.fromIterator(
            iterator as Iterator<Iterable<String>>);
      }
    }
    var n = iterator!.moveNext();
    if (n) {
      _current = iterator!.current;
      return true;
    } else {
      return false;
    }
  }

  @override
  bool isMatch(String id) => indexer._isMatch(id, expression);
}

///
class UniqueIndexMatch extends IndexMatch {
  ///
  UniqueIndexMatch(this.indexer, this.expression);

  ///
  Iterator<List<String>>? iterator;

  ///
  Indexer indexer;

  ///
  MatchExpression expression;

  Iterator<List<String>> _getIterator() {
    throw UnimplementedError();
  }

  ///
  String? _current;

  @override
  String get current => _current!;

  @override
  bool moveNext() {
    iterator ??= _getIterator();
    return iterator!.moveNext();
  }

  @override
  bool isMatch(String id) => indexer._isMatch(id, expression);
}

///
class AndIndexMatch extends IndexMatch {
  ///
  AndIndexMatch(this.matches) : assert(matches.length > 1);

  ///
  final List<IndexMatch> matches;

  @override
  String get current => _current!;

  String? _current;

  bool _setFirst() {
    throw UnimplementedError();
  }

  @override
  bool moveNext() {
    if (_current == null) {
      return _setFirst();
    }

    matches_loop:
    while (matches.first.moveNext()) {
      var k = matches.first.current;
      var m = false;
      for (var i = 1; i < matches.length; i++) {
        m = matches[i].isMatch(k);
        if (!m) {
          continue matches_loop;
        }
      }
      _current = k;
      return true;
    }
    return false;
  }

  @override
  bool isMatch(String id) {
    for (var m in matches) {
      if (m.isMatch(id)) {
        return false;
      }
    }
    return true;
  }
}

///
class OrIndexMatch extends IndexMatch {
  ///
  OrIndexMatch(
    this.matches,
  ) : assert(matches.length > 1);

  ///
  final List<IndexMatch> matches;

  @override
  String get current => _current!;

  String? _current;

  bool _setFirst() {
    throw UnimplementedError();
  }

  @override
  bool moveNext() {
    if (_current == null) {
      return _setFirst();
    }

    while (matches.first.moveNext()) {
      var k = matches.first.current;
      var m = false;
      for (var i = 1; i < matches.length; i++) {
        m = matches[i].isMatch(k);
        if (m) {
          _current = k;
          return true;
        }
      }
    }

    return false;
  }

  @override
  bool isMatch(String id) {
    for (var m in matches) {
      if (m.isMatch(id)) {
        return true;
      }
    }
    return false;
  }
}
