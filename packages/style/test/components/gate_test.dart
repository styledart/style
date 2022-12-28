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

import 'package:style_dart/src/style_base.dart';
import 'package:style_test/style_test.dart';

void main() async {
  await initStyleTester(
      'gate',
      Server(children: [
        Gate(
            child: Gateway(children: [
              Route('a', root: SimpleEndpoint((r, c) => 'Body is ${r.body}')),
              Route('b', root: SimpleEndpoint((r, c) => 'responded with endpoint'))
            ]),
            onRequest: (r) {
              if (r.nextPathSegment == 'b') {
                return r.response(Body('responded with gate'));
              }
              return r..body = Body('in gate');
            }),
      ]), (tester) async {
    tester('/a', bodyIs('Body is in gate'));
    tester('/b', bodyIs('responded with gate'));
  });
}
