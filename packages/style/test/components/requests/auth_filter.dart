// import 'package:http/http.dart';
// import 'package:style/style_dart.dart';
// import 'package:test/expect.dart';
// import 'package:test/scaffolding.dart';
//
// void main() async {
//   var binding = runService(Server(children: [
//     AuthFilterGate(
//         authRequired: true,
//         child: Route("auth_filter",
//             root: SimpleEndpoint((request) => request
//                 .createResponse({"token": request.context.accessToken}))))
//   ]));
//
//   await binding.owner.httpService.ensureInitialize();
//
//   test("auth", () async {
//     var nonAuth = await get(Uri.parse("http://localhost/auth_filter"));
//
//     print(nonAuth.body);
//     expect(nonAuth.statusCode.toString().startsWith("4"), true);
//
//     var authorized = await post(Uri.parse("http://localhost/auth_filter?token=some"));
//
//     print(authorized.body);
//     expect(authorized.statusCode.toString().startsWith("2"), true);
//   });
// }
