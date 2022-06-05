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

abstract class NotExistsException implements Exception {
  String get obj;

  @override
  String toString() => '$obj not exists';
}

class CollectionNotExists extends NotExistsException {
  CollectionNotExists(this.name);

  String name;

  @override
  String get obj => 'collection:$name';
}

class DocumentNotExists extends NotExistsException {
  DocumentNotExists(this.collection, this.id);

  String? id;
  String collection;

  @override
  String get obj => 'document:$id in a collection:$collection';
}

class CollectionEmpty implements Exception {
  CollectionEmpty(this.collection);

  String collection;

  @override
  String toString() => '$collection is empty';
}

class UniqueValueDuplicatedException implements Exception {
  UniqueValueDuplicatedException(this.key, this.value);

  ///
  String key;

  dynamic value;

  @override
  String toString() => 'Unique value duplicated: $key:$value';
}
