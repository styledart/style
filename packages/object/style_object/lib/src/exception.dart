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

class DuplicateKeyException implements Exception {
  DuplicateKeyException({this.key, this.tag});

  int? key;
  String? tag;

  @override
  String toString() {
    return 'Duplicated ${key != null ? 'key' : 'tag'} : ${key ?? tag}';
  }
}

class ReservedException implements Exception {
  @override
  String toString() {
    return 'Key "0" and tag "#root" are reserved';
  }
}
