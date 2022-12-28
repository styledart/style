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
//   group("num", () {
//     var a = 10;
//     var b = 20;
//     var c = 10;
//     var d = 40;
//     var e = 5;
//
//     var map = {"a": 10, "b": 20, "c": 10, "d": 40, "e": 5};
//
//
//
//
//     test("gt", () {
//       var exp = Greater("b", b);
//       expect(exp.compareTo(a), false);
//       expect(exp.compareTo(d), true);
//     });
//
//     test("gt_isMatch", () {
//       expect(Greater("a", b).documentIsMatch(map), false);
//       expect(Greater("d", b).documentIsMatch(map), true);
//     });
//
//
//     test("gte", () {
//       var exp = GreaterOrEqual("c", c);
//       expect(exp.compareTo(a), true);
//       expect(exp.compareTo(e), false);
//     });
//
//     test("gte_isMatch", () {
//       expect(GreaterOrEqual("a", c).documentIsMatch(map), true);
//       expect(GreaterOrEqual("e", c).documentIsMatch(map), false);
//     });
//
//     test("ls", () {
//       var exp = Less("c", c);
//       expect(exp.compareTo(e), true);
//       expect(exp.compareTo(b), false);
//     });
//
//     test("ls_isMatch", () {
//       expect(Less("e", c).documentIsMatch(map), true);
//       expect(Less("b", c).documentIsMatch(map), false);
//     });
//
//     test("lse", () {
//       var exp = LessOrEqual("c", c);
//       expect(exp.compareTo(e), true);
//       expect(exp.compareTo(b), false);
//       expect(exp.compareTo(a), true);
//     });
//
//     test("lse_isMatch", () {
//       expect(LessOrEqual("e", c).documentIsMatch(map), true);
//       expect(LessOrEqual("b", c).documentIsMatch(map), false);
//       expect(LessOrEqual("a", c).documentIsMatch(map), true);
//     });
//
//   });
// }
