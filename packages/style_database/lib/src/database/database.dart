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

part of '../style_database_base.dart';

///
class Database {
  ///
  Database({RandomGenerator? idGenerator, this.autoIndex = true})
      : idGenerator = idGenerator ?? RandomGenerator('[#*]/l(30)');

  ///
  RandomGenerator idGenerator;

  ///
  bool opened = false;

  ///
  bool autoIndex;

  ///
  Map<String, Collection> collections = {};

  ///
  FutureOr<JsonMap> read(CommonAccess access) {
    if (collections[access.collection] == null) {
      throw CollectionNotExists(access.collection);
    }
    return collections[access.collection]!.read(query: access.query);
  }

  ///
  FutureOr<List<JsonMap>> readMultiple(CommonAccess access) {
    if (collections[access.collection] == null) {
      throw CollectionNotExists(access.collection);
    }
    return collections[access.collection]!.readMultiple(query: access.query);
  }


  ///
  void create(CommonAccess access) {
    collections[access.collection] ?? Collection(access.collection, this);
    collections[access.collection]!.add(access.create!.toMap());
  }

  ///
  void createIndexes<T>(
    String collection,
    String field, {
    bool unique = false,
    bool ascending = true,
  }) {
    collections[collection] ??= Collection(collection, this);
    (collections[collection]!).createIndexes<T>(field);
  }
}
