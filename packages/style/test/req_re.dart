import 'package:style/src/style_base.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  var req = HttpRequest(
      context: RequestContext(
          fullPath: "host/path/to/endpoint",
          agent: Agent.http,
          cause: Cause.admin,
          createContext: NoComponent().createBinding(),
          requestTime: DateTime.now(),
          currentContext: NoComponent().createBinding()),
      body: {"": ""});

  test("req", () {
    expect(req.fullPath, "host/path/to/endpoint");
    var res = req.createResponse({"a": "b"});
    expect(res.body, {"a": "b"});
    expect(res.responseCreated, true);
  });
}

class NoComponent extends StatelessComponent {
  const NoComponent({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) {
    return UnknownEndpoint();
  }
}
