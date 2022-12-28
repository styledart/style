// /*
//  * Copyright 2021 styledart.dev - Mehmet Yaz
//  *
//  * Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE,
//  *    Version 3 (the "License");
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  *       https://www.gnu.org/licenses/agpl-3.0.en.html
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an "AS IS" BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  *
//  */
//
// import 'package:style_query/style_query.dart';
// import 'package:test/expect.dart';
// import 'package:test/scaffolding.dart';
//
// void main() {
//   group("match", () {
//     var a = 10;
//     var b = 20;
//     var c = 10;
//
//     var map = {"a": 10, "b": 20, "c": 10, "d": 40, "e": 5};
//
//     test("eq", () {
//       var exp = EqualExpression("a", a);
//       expect(exp.compareTo(c), true);
//       expect(exp.compareTo(b), false);
//     });
//
//     test("eq_isMatch", () {
//       expect(EqualExpression("c", a).documentIsMatch(map), true);
//       expect(EqualExpression("b", a).documentIsMatch(map), false);
//     });
//
//     test("ne", () {
//       var exp = NotEqual("a", a);
//       expect(exp.compareTo(c), false);
//       expect(exp.compareTo(b), true);
//     });
//
//     test("ne_isMatch", () {
//       expect(NotEqual("c", a).documentIsMatch(map), false);
//       expect(NotEqual("b", a).documentIsMatch(map), true);
//     });
//   });
// }
