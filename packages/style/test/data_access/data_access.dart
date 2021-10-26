/*
 * Copyright (c) 2021. This code was written by Mehmet Yaz.
 * Mehmet Yaz does not accept the problems that may arise due to these codes.
 */

import 'package:style_dart/style_dart.dart';
import 'package:style_test/style_test.dart';
import 'package:test/expect.dart';

void main() {
  initStyleTester("data_access", _MyServer(), (tester) {
    tester("/api/users", statusCodeIs(200),
        methods: Methods.POST,
        body: {"_id": "my_user1", "name": "Mehmet", "l_name": "Yaz"});
    tester(
        "/api/users/my_user1",
        allOf(statusCodeIs(200),
            bodyIs({"_id": "my_user1", "name": "Mehmet", "l_name": "Yaz"})),
        methods: Methods.GET);
  });
}

class _MyServer extends StatelessComponent {
  const _MyServer({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) {
    return Server(
        dataAccess: DataAccess(SimpleCacheDataAccess(),
            defaultPermission: false, collections: []),
        children: [SimpleAccessPoint("api")]);
  }
}
