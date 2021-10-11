import 'dart:async';
import 'dart:io';

import 'package:stack_trace/stack_trace.dart';
import 'package:style/style.dart';

/// Bu App Güzel Çalışacak
void main() async {
  print("""
        Traces
        ${Trace.current().frames}
        Bitti
        """);

  var b = runService(ShelfExample());

  b.visitChildren(TreeVisitor((visitor) {
    try {
      print("${visitor.currentValue.component}"
          " ${visitor.currentValue.httpService}");
    } on Exception {
      print("${visitor.currentValue.component} on Null");
    }
  }));
}

class MyEx implements Exception {
  @override
  String toString() => "TEST EXCEPTION";
}

class UnauthorizedEndpoint extends ExceptionEndpoint<UnauthorizedException> {
  @override
  FutureOr<Response> onError(
      Message message, UnauthorizedException exception, StackTrace stackTrace) {
    if (message.contentType?.mimeType == ContentType.json.mimeType) {
      return (message as Request)
          .createResponse({"error": "unauthorized_error"});
    } else {
      return (message as Request).createResponse(HtmlBody("""
<html>
    <body>
      <center style="vertical-align: middle;">
        <h1>
          You are not allowed inside
        </h1>
        <span style="padding-top: 20px;">
        <p align='left'>
        ${stackTrace.toString().split("\n").join("<br>")}
        </p>     
      </center>
    </body>
  </html>
      """));
    }
  }
}

/// TODO: Document
class GetUserAppointments extends Endpoint {
  GetUserAppointments() : super();

  @override
  FutureOr<Message> onCall(Request request) {
    // TODO: implement onCall
    throw UnimplementedError();
  }
}

class ShelfExample extends StatelessComponent {
  const ShelfExample({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) {
    return Server(rootEndpoint: Redirect("../web/index.html"), children: [
      // Static handler
      // Route("web", root: DocumentService("/dir"), handleUnknownAsRoot: true),
      ExceptionWrapper<StyleException>(
          child: Route("time", root: Throw(Exception())),
          exceptionEndpoint: ClientExEnd()),



      Route("hello",
          root: SimpleEndpoint((req) => req.createResponse("hello"))),
      MathOperationRoute("sum", (a, b) => a + b),
      MathOperationRoute("mul", (a, b) => a * b),
      MathOperationRoute("div", (a, b) => a / b),
      MathOperationRoute("dif", (a, b) => a - b)
    ]);
  }
}

/// TODO: Document
class ClientExEnd extends ExceptionEndpoint<StyleException> {
  ClientExEnd() : super();

  @override
  FutureOr<Response> onError(
      Message message, StyleException exception, StackTrace stackTrace) {
    return (message as Request).createResponse({
      "err": "client_error_received",
      "type": "${exception.runtimeType}",
      "sup": "${exception.superType}",
      "st": stackTrace.toString()
    });
  }
}

class MathOperationRoute extends StatelessComponent {
  MathOperationRoute(this.name, this.operation);

  final String name;
  final num Function(int a, int b) operation;

  @override
  Component build(BuildContext context) {
    return ExceptionWrapper(
        child: Route(name,
            root: Throw(FormatException()),
            child: RouteTo("{a}",
                root: Throw(FormatException()),
                child: RouteTo("{b}", root: SimpleEndpoint((request) {
                  var a = int.parse(request.arguments["a"]);
                  var b = int.parse(request.arguments["b"]);
                  return request.createResponse({
                    {"a": a, "b": b, name: operation(a, b)}
                  });
                })))),
        exceptionEndpoint: FormatExEnd());
  }
}

class Throw extends SimpleEndpoint {
  Throw(Exception exception) : super((re) => throw exception);
}

class FormatExEnd extends ExceptionEndpoint<FormatException> {
  @override
  FutureOr<Response> onError(
      Message message, FormatException exception, StackTrace stackTrace) {
    return (message as Request).createResponse(
        "please ensure path like: \"host/{sum|div|dif|mul}/{number}/{number}\"");
  }
}

///
class MyServer extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Server(
        rootName: "my_server",
        defaultExceptionEndpoints: {
          UnauthorizedException: UnauthorizedEndpoint(),
        },
        faviconDirectory: "D:\\style\\packages\\style\\assets",
        children: [
          Route("any_ex",
              root: SimpleEndpoint((request) => throw UnauthorizedException())),
          // AuthFilterGate(
          //     authRequired: true,
          //     child: Route(
          //         "appointments",
          //         root: GetUserAppointments(),
          //         child: RouteTo(
          //             "{stylist_id}",
          //             child: RouteTo("{day}",
          //                 child: CallQueue(
          //                     Gateway(
          //                       children: [
          //
          //                         Route(
          //                            "create",
          //                            root: MethodFilterGate(
          //                                allowedMethods: [Methods.GET],
          //                                child: SimpleEndpoint(/**/))),
          //                         Route("delete", root: SimpleEndpoint(/**/))
          //                       ]
          //                     )
          //                 )
          //             )
          //         )
          //     )
          // ),
          AuthFilterGate(
              authRequired: true,
              child: Route("appointments",
                  root: GetUserAppointments(),
                  child: RouteTo("{stylist_id}",
                      child: RouteTo("{day}",
                          child: CallQueue(Gateway(children: [
                            Route("create",
                                root: MethodFilterGate(
                                    allowedMethods: [Methods.GET],
                                    child: SimpleEndpoint((req) async {
                                      await Future.delayed(
                                          Duration(milliseconds: 500));
                                      throw Exception("unimplemented");
                                    }))),
                            Route("delete", root: SimpleEndpoint((req) async {
                              await Future.delayed(Duration(milliseconds: 500));
                              throw Exception("unimplemented");
                            }))
                          ])))))),

          // Post(),
          User(),
          Route("c_t",
              root: SimpleEndpoint((request) => request.createResponse({
                    "type": request.contentType?.mimeType,
                    "body": request.body?.data.runtimeType.toString()
                  }))),
          Route("api", root: SimpleAccessPoint(), handleUnknownAsRoot: true),
          Route("doc",
              handleUnknownAsRoot: true,
              root: DocumentService("D:\\style\\packages\\style\\source\\web\\",
                  cacheAll: false)),
          MethodFilterGate(
              allowedMethods: [Methods.GET],
              child: AuthFilterGate(
                  authRequired: true, child: Route("auth", root: AuthEnd()))),
          Route("un-auth", root: CallQueue(UnAuthEnd())),
        ],
        // defaultUnknownEndpoint: SimpleEndpoint((r) {
        //   print("Buraya Geldi");
        //   return r.createResponse({"route": "un"});
        // }),
        rootEndpoint: Redirect("http://localhost/doc/index.html"));
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
    try {
      print("Cevap Gitti UN: ${context.dataAccess}");
      return request.createResponse({"args": "FROM UNAUTH"});
    } on Exception catch (e) {
      print("ON 2 $e");
      rethrow;
    }
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
