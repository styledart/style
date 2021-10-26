import 'dart:io';

import 'package:style_dart/style_dart.dart';
import 'package:style_test/style_test.dart';
import 'package:test/test.dart';

void main() {
  initStyleTester("MyServerBaseTest", MyTestServer(), (tester) {
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
          child:
              Route("onlyAuth", root: SimpleEndpoint.static("you are auth"))),
      Route("everyone", root: SimpleEndpoint.static("it does not matter"))
    ]);
  }
}
