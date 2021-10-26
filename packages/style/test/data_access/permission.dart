/*
 * Copyright (c) 2021. This code was written by Mehmet Yaz.
 * Mehmet Yaz does not accept the problems that may arise due to these codes.
 */

import 'package:style_dart/style_dart.dart';
import 'package:style_test/style_test.dart';

void main() async {
  ///
  initStyleTester("permission_test", _MyServer(), (tester) {
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
              DbCollection("pass",
                  permissionHandler: PermissionHandler.custom((event) {
                return true;
              })),
              DbCollection("fail",
                  permissionHandler: PermissionHandler.custom((event) {
                return false;
              })),
              DbCollection("pass_static",
                  permissionHandler: PermissionHandler.static(
                      defaultPermission: false, read: true))
            ]),
        children: [SimpleAccessPoint("api")]);
  }
}
