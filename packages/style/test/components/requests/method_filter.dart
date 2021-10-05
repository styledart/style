import 'package:http/http.dart';
import 'package:style/style.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() async {
  var binding = runService(Server(children: [
    MethodFilterGate(
        blockedMethods: [Methods.GET],
        child: Route("method_filter",
            root: SimpleEndpoint(
                (request) => request.createResponse({"from_method"}))))
  ]));

  await binding.owner.httpService.ensureListening();

  test("method", () async {
    var getRes = await get(Uri.parse("http://localhost/method_filter"));

    print(getRes.body);
    expect(getRes.statusCode.toString().startsWith("4"), true);

    var postRes = await post(Uri.parse("http://localhost/method_filter"));

    print(postRes.body);
    expect(postRes.statusCode.toString().startsWith("2"), true);
  });
}
