import 'dart:async';

import 'package:stack_trace/stack_trace.dart';
import 'package:style/style.dart';

/// Bu App Güzel Çalışacak
void main() async {
  print("""
        Traces
        ${Trace.current().frames}
        Bitti
        """);

  runService(MyServer());
}

///
class MyServer extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Server(
        rootName: "my_server",
        faviconDirectory: "D:\\style\\packages\\style\\assets",
        children: [
          Route("appointments",
              child: RouteTo("{stylist_id}",
                  child: RouteTo("{day}",
                      child: CallQueue(Gateway(children: [
                        Route("create", root: SimpleEndpoint((req) => throw 0)),
                        Route("delete", root: SimpleEndpoint((req) => throw 0))
                      ]))))),
          Post(),
          User(),
          Route("c_t",
              root: SimpleEndpoint((request) => request
                  .createResponse({"type": request.contentType?.mimeType}))),
          Route("api",
              root: RequestTrigger(
                  ensureResponded: true,
                  child: ResponseTrigger(
                      ensureSent: true,
                      child: SimpleAccessPoint(),
                      trigger: (res) {
                        print("RES TRIGGER: ${res.body}");
                      }),
                  trigger: (req) {
                    print("REQ TRIGGER: ${req.fullPath}");
                  }),
              handleUnknownAsRoot: true),
          Route("doc",
              handleUnknownAsRoot: true,
              root: DocumentService("D:\\style\\packages\\style\\source\\",
                  cacheAll: false)),
          MethodFilterGate(
              blockedMethods: [Methods.GET],
              child: AuthFilterGate(
                  authRequired: true, child: Route("auth", root: AuthEnd()))),
          Route("un-auth", root: CallQueue(UnAuthEnd())),
        ],
        rootEndpoint: UnknownEndpoint());
  }
}

/// For Http Deneme

/// TODO: Document
class MyServerUnknown extends Endpoint {
  ///
  MyServerUnknown() : super();

  @override
  FutureOr<Message> onCall(Request request) {
    // TODO: implement onCall
    throw UnimplementedError();
  }
}

///
class User extends StatelessComponent {
  ///
  const User({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) {
    return Route("user",
        handleUnknownAsRoot: true,
        child:
            RouteTo("{api_key}", root: GeneratedRedirect(generate: (req) async {
          if (req.path.arguments["api_key"] == "v1") {
            return "../../auth";
          } else if (req.path.arguments["api_key"] == "v2") {
            return "../../un-auth";
          }
        })),
        root: AuthRedirect(authorized: "../auth", unauthorized: "../un-auth"));
  }
}

class UnAuthEnd extends Endpoint {
  @override
  FutureOr<Message> onCall(Request request) async {
    await Future.delayed(Duration(seconds: 2));
    print("Cevap Gitti UN");
    return request.createResponse({"args": "FROM UNAUTH"});
  }
}

class AuthEnd extends Endpoint {
  @override
  FutureOr<Message> onCall(Request request) {
    return request.createResponse({"args": "FROM AUTH"});
  }
}

class Post extends StatelessComponent {
  const Post({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) {
    return Route("{post_id}",
        root: Redirect("https://www.google.com/search?q={post_id}"),
        // root: Gate(
        //     child: PostEnd(),
        //     onRequest: (req) async {
        //       if (req.path.arguments["post_id"] == "user") {
        //         throw Exception("Exception");
        //
        //         return req.createJsonResponse({"mes": "Gate Cevap Verdi"});
        //       }
        //       return req;
        //     }),
        handleUnknownAsRoot: false);
  }
}

/// TODO: Document
class PostEnd extends Endpoint {
  PostEnd() : super();

  @override
  FutureOr<Message> onCall(Request request) {
    return request.createResponse({"args": request.path.arguments});
  }
}

class MyUserEndpoint extends Endpoint {
  @override
  FutureOr<Message> onCall(Request request) {
    return request.createResponse({"args": "FROM LANG"});
  }
}

//
// class FaviconLoader extends StatefulComponent {
//   const FaviconLoader({GlobalKey? key}) : super(key: key);
//
//   @override
//   FaviconLoaderState createState() => FaviconLoaderState();
// }
//
// class FaviconLoaderState extends State<FaviconLoader> {
//   Uint8List? data;
//
//   ///
//   Future<void> _loadIcon() async {
//     var file = File("D:\\style\\packages\\style\\assets\\favicon.ico");
//     data = await file.readAsBytes();
//   }
//
//   @override
//   Component build(BuildContext context) {
//     return Favicon();
//   }
// }
//
// ///
// class Favicon extends Endpoint {
//   Favicon() : super();
//
//   @override
//   FutureOr<Message> onCall(Request request) async {
//     var state = context.findAncestorStateOfType<FaviconLoaderState>()!;
//     if (state.data == null) {
//       await state._loadIcon();
//     }
//     var base = (request as HttpRequest).baseRequest;
//     base.response.contentLength = state.data!.length;
//     base.response.headers
//         .add(HttpHeaders.contentTypeHeader, ContentType.binary.mimeType);
//     base.response.add(state.data!);
//     base.response.close();
//     return NoResponseRequired(request: request);
//   }
// }
