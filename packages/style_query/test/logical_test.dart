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

import 'package:style_query/style_query.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group("num", () {
    var b = 20;
    var c = 10;

    var map = {"a": 10, "b": 20, "c": 10};

    var t = GreaterOrEqual("a", c);
    var f = Greater("a", b);

    var tA = AndExpression([t, t]);
    var fA = AndExpression([t, f]);

    test("and", () {
      expect(AndExpression([t, f]).documentIsMatch(map), false);
      expect(AndExpression([t, t]).documentIsMatch(map), true);
      expect(AndExpression([f, f]).documentIsMatch(map), false);
      expect(AndExpression([tA, t]).documentIsMatch(map), true);
    });

    test("or", () {
      expect(OrExpression([t, f]).documentIsMatch(map), true);
      expect(OrExpression([f, f]).documentIsMatch(map), false);
      expect(OrExpression([t, t]).documentIsMatch(map), true);
      expect(OrExpression([t, fA]).documentIsMatch(map), true);
    });
  });
}
