/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import 'package:style_dart/src/style_base.dart';
import 'package:style_test/style_test.dart';

void main() {
  var str1 = """
  
  <html>
    Hello
  </html>
  
  """;

  var str2 = """<html>
    Hello
  </html>
  """;

  var str3 = """
  Hello
  """;
  var str4 = """
                       
  """;

  test("description", () {
    expect(Body.isHtml(str1), true);
    expect(Body.isHtml(str2), true);
    expect(Body.isHtml(str3), false);
    expect(Body.isHtml(str4), false);
  });
}
