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

import 'dart:io';

import 'package:style_dart/style_dart.dart';
import 'package:style_test/style_test.dart';

void main() async {
  initStyleTester("MyServerBaseTest", MyTestServer(), (tester) async {

    tester("/onlyAuth", statusCodeIs(401));

    tester("/onlyAuth", anyOf(statusCodeIs(200), bodyIs("you are auth")),
        headers: {HttpHeaders.authorizationHeader: "Bearer MyToken"});
  });
}



class MyTestServer extends StatelessComponent {
  const MyTestServer({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) {
    return Server(children: [
      AuthFilterGate(
          child: RouteBase("onlyAuth",
              root: SimpleEndpoint.static("you are auth"))),
      RouteBase("everyone", root: SimpleEndpoint.static("it does not matter"))
    ]);
  }
}
