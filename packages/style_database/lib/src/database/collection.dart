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
class Collection {
  ///
  Collection(this.name, this._database);

  ///
  String name;

  ///
  Map<String, Indexer> indexes = {};

  final Storage storage = MemoryStorage();

  ///
  final Database _database;

  ///
  void add(JsonMap data) {
    data[_idKey] ??= _database.idGenerator.generateString();
    if (indexes.isNotEmpty) {
      for (var key in indexes.keys) {
        indexes[key]!.indexObject(data[_idKey] as String, data[key] as Object);
      }
    }
    storage.create(data);
  }

  ///
  void createIndexes<T>(String field,
      {bool unique = false, bool ascending = true, bool compound = false}) {
    indexes[field] = SortedIndex<int>(field,
        ascending: ascending, database: _database, unique: unique);
  }

  FutureOr<JsonMap> read({Query? query}) {
    if (query == null) {
      var it = storage.iterator;
      if (it.moveNext()) {
        var res = storage.read(it.current);
        if (res == null) {
          throw DocumentNotExists(name, it.current);
        } else {
          return res as JsonMap;
        }
      } else {
        throw CollectionEmpty(name);
      }
    } else {
      JsonMap? result;
      if (query.identifier != null) {
        result = storage.read(query.identifier!) as JsonMap?;
        if (result == null) {
          throw DocumentNotExists(name, query.identifier);
        }
      } else if (query.filter != null) {
        var exp = query.filter as Greater;
        var indexer = indexes[exp.key];

        IndexMatch match;
        if (indexer == null) {
          if (_database.autoIndex) {
            createIndexes<int>(exp.key);
            match = ExpressionIndexMatch(indexes[exp.key]! as SortedIndex, exp);
          } else {
            match = ScanMatch(storage, exp);
          }
        } else {
          match = ExpressionIndexMatch(indexer as SortedIndex, exp);
        }

        var n = match.moveNext();
        if (n) {
          result = storage.read(match.current) as JsonMap;
        } else {
          throw DocumentNotExists(name, null);
        }
      }

      if (result == null) {
        throw DocumentNotExists(name, null);
      }

      /// Check fields

      return result;
    }
  }

  FutureOr<List<JsonMap>> readMultiple({Query? query}) {
    if (query == null) {
      var it = storage.iterator;
      var _list = <JsonMap>[];
      while (it.moveNext()) {
        var res = storage.read(it.current);
        if (res == null) {
          throw DocumentNotExists(name, it.current);
        } else {
          _list.add(res as JsonMap);
        }
      }
      return _list;
    } else {
      if (query.filter != null) {
        var exp = query.filter as Greater;
        var indexer = indexes[exp.key];

        IndexMatch match;
        if (indexer == null) {
          if (_database.autoIndex) {
            createIndexes<int>(exp.key);
            match = ExpressionIndexMatch(indexes[exp.key]! as SortedIndex, exp);
          } else {
            match = ScanMatch(storage, exp);
          }
        } else {
          match = ExpressionIndexMatch(indexer as SortedIndex, exp);
        }

        var _list = <JsonMap>[];

        while (match.moveNext()) {
          var result = storage.read(match.current);
          if (result == null) {
            throw DocumentNotExists(name, match.current);
          } else {
            //TODO: Check fields
            _list.add(result as JsonMap);
          }
        }

        return _list;
      }
      throw UnimplementedError();
    }
  }
}
