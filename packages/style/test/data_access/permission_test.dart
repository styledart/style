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

import 'package:style_dart/style_dart.dart';
import 'package:style_test/style_test.dart';

void main() async {
  ///
  await initStyleTester("permission_test", _MyServer(), (tester) async {
    tester("/api/pass", statusCodeIs(200), methods: Methods.GET);
    tester("/api/fail", statusCodeIs(403), methods: Methods.GET);
    tester("/api/pass_static", statusCodeIs(200), methods: Methods.GET);
  });
}

class _MyServer extends StatelessComponent {
  const _MyServer({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) {
    return Server(
        dataAccess: DataAccess(SimpleCacheDataAccess(),
            defaultPermission: false,
            collections: [
              DbCollection("pass", permissionHandler:
                  PermissionHandler.custom(callback: (event) {
                return true;
              })),
              DbCollection("fail", permissionHandler:
                  PermissionHandler.custom(callback: (event) {
                return false;
              })),
              DbCollection("pass_static",
                  permissionHandler: PermissionHandler.static(
                      defaultPermission: false, read: true))
            ]),
        children: [RestAccessPoint("api")]);
  }
}
