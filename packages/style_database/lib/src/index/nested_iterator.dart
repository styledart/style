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

/// Nested iterator iterate T of Iterable<Iterable<T>>
///
/// [
///   ["A" , "B"],
///   ["C" , "D"]
/// ]
///
/// iterate : "A" , "B" , "C" , "D"
///
class NestedIterator<T> extends Iterator<T> {
  NestedIterator(Iterable<Iterable<T>> iterable)
      : _iterableIterator = iterable.iterator;

  NestedIterator.fromIterator(this._iterableIterator);

  ///
  final Iterator<Iterable<T>> _iterableIterator;

  ///
  T? _current;

  @override
  T get current => _current!;

  ///
  Iterator<T>? _currentIterator;

  @override
  bool moveNext() {



    while(true) {
      if (_currentIterator == null) {
        var n =  _iterableIterator.moveNext();
        if (n) {
          _currentIterator = _iterableIterator.current.iterator;
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
