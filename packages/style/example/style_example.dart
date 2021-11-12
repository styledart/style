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

import 'dart:async';
import 'dart:io';

import 'package:stack_trace/stack_trace.dart';
import 'package:style_dart/style_dart.dart';

/// Bu App Güzel Çalışacak
void main() async {
  print("""
        Traces
        ${Trace.current().frames}
        Bitti
        """);

  runService(ShelfExample());

  // b.visitChildren(TreeVisitor((visitor) {
  //   try {
  //     print("${visitor.currentValue.component}"
  //         " ${visitor.currentValue.httpService}");
  //   } on Exception {
  //     print("${visitor.currentValue.component} on Null");
  //   }
  // }));
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
      return (message as Request).response({"error": "unauthorized_error"});
    } else {
      return (message as Request).response(HtmlBody("""
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
    return Server(httpService: DefaultHttpServiceHandler(), children: [
      // ContentDelivery("D:\\style\\packages\\style\\data\\",
      //     cacheFiles: true, useLastModified: true),

      // RouteBase("*root",
      //     child: DocumentService("D:\\style\\packages\\style\\site\\build"),
      //     handleUnknownAsRoot: true),

      // Route("*root",
      //     root: SimpleEndpoint((request) => request.response("unk"))),
      // Route("{a}", root: SimpleEndpoint((request)
      // => request.response("body"))),
      // Route("{b}",
      //     root: SimpleEndpoint((request) =>
      //     request.createResponse("body2")))
      //     ,
      // Static handler
      // Route("web", root: DocumentService("/dir"), handleUnknownAsRoot: true),
      CacheControl(
          cacheability: Cacheability.public(),
          expiration: Expiration.maxAge(Duration(seconds: 10)),
          child: RouteBase("modified1", root: MyIfNoneMatchEnd())),

      CacheControl(
          cacheability: Cacheability.public(),
          expiration: Expiration.maxAge(Duration(seconds: 10)),
          child: RouteBase("modified2", root: SimpleEndpoint((r, __) {
            return r.response("""<html>
              <script src='/modified1' type='application/javascript'></script>
              <h1>Hello</h1>
            </html>""");
          }))),
      MathRoutes()

      // ExceptionWrapper<StyleException>(
      //     child: Route("time", root: Throw(Exception())),
      //     exceptionEndpoint: ClientExEnd()),
      // Route("hello", root:
      // SimpleEndpoint((req) => req.response("hello"))),

      // Route("json", root: SimpleEndpoint((request) {
      //   print(
      //       "REQ: ${request.fullPath}\nQUERY:${request.path.queryParameters}");
      //   return request.response({
      //     "q": request.path.queryParameters,
      //     "enc": json.decode(request.path.queryParameters["q"]),
      //     "fr": json
      //         .decode(request.path.queryParameters["q"])["from"]
      //         .runtimeType
      //         .toString()
      //   });
      // })),
    ]);
  }
}

class MathRoutes extends StatelessComponent {
  const MathRoutes({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) {
    return Gateway(children: [
      MathOperationRoute("sum", (a, b) => a + b),
      MathOperationRoute("mul", (a, b) => a * b),
      MathOperationRoute("div", (a, b) => a / b),
      MathOperationRoute("dif", (a, b) => a - b),
    ]);
  }
}

/// TODO: Document
class ClientExEnd extends ExceptionEndpoint<StyleException> {
  ClientExEnd() : super();

  @override
  FutureOr<Response> onError(
      Message message, StyleException exception, StackTrace stackTrace) {
    return (message as Request).response({
      "err": "client_error_received",
      "type": "${exception.runtimeType}",
      "sup": "${exception.superType}",
      "st": stackTrace.toString()
    });
  }
}

/// TODO: Document
class MyIfNoneMatchEnd extends StatefulEndpoint {
  MyIfNoneMatchEnd() : super();

  @override
  EndpointState<StatefulEndpoint> createState() => _EndState();
}

class _EndState extends EndpointState<MyIfNoneMatchEnd> {
  ///
  DateTime last = DateTime.now();

  late String val = getRandomId(30);

  @override
  FutureOr<Object> onCall(Request request) {
    print("Request: ${request.headers}");
    return request.response("""
    document.write(5 + 6);
    """, contentType: ContentType("application", "javascript"));
  }
}
// /// TODO: Document
// class MyIfNoneMatchEnd extends StatefulEndpoint {
//   MyIfNoneMatchEnd() : super();
//
//   @override
//   EndpointState<StatefulEndpoint> createState() => _EndState();
// }
//
// class _EndState extends EtagEndpointState<MyIfNoneMatchEnd> {
//   ///
//   DateTime last = DateTime.now();
//
//   late String val = getRandomId(30);
//
//   @override
//   void initState() {
//     Timer.periodic(Duration(seconds: 20), (timer) {
//       print("Değişti");
//       val = getRandomId(30);
//       last = DateTime.now();
//     });
//     super.initState();
//   }
//
//   @override
//   FutureOr<ResponseWithEtag> onRequest(ValidationRequest<String> request) {
//     print("NORMAL CALL: Have Logger ${context.hasService<Logger>()}");
//
//     return ResponseWithEtag({"val": val, "last": last.toString()},
//         request: request, etag: val);
//   }
//
//
// }

class MathOperationRoute extends StatelessComponent {
  MathOperationRoute(this.name, this.operation);

  final String name;
  final num Function(int a, int b) operation;

  @override
  Component build(BuildContext context) {
    return ExceptionWrapper(
        child: RouteBase(name,
            root: Throw(FormatException()),
            child: SubRoute("{a}",
                root: Throw(FormatException()),
                child: SubRoute("{b}", root: SimpleEndpoint((request, _) {
                  var a = int.parse(request.arguments["a"]);
                  var b = int.parse(request.arguments["b"]);
                  return {"a": a, "b": b, name: operation(a, b)};
                })))),
        exceptionEndpoint: FormatExEnd());
  }
}

///
class FormatExEnd extends ExceptionEndpoint<FormatException> {
  @override
  FutureOr<Response> onError(
      Message message, FormatException exception, StackTrace stackTrace) {
    return (message as Request).response(
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
          RouteBase("any_ex",
              root: SimpleEndpoint(
                  (request, _) => throw UnauthorizedException())),
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
              child: RouteBase("appointments",
                  root: GetUserAppointments(),
                  child: SubRoute("{stylist_id}",
                      child: SubRoute("{day}",
                          child: CallQueue(Gateway(children: [
                            RouteBase("create",
                                root: MethodFilterGate(
                                    allowedMethods: [Methods.GET],
                                    child: SimpleEndpoint((req, _) async {
                                      await Future.delayed(
                                          Duration(milliseconds: 500));
                                      throw Exception("unimplemented");
                                    }))),
                            RouteBase("delete",
                                root: SimpleEndpoint((req, _) async {
                              await Future.delayed(Duration(milliseconds: 500));
                              throw Exception("unimplemented");
                            }))
                          ])))))),

          // Post(),
          User(),
          RouteBase("c_t",
              root: SimpleEndpoint((request, _) => request.response({
                    "type": request.contentType?.mimeType,
                    "body": request.body?.data.runtimeType.toString()
                  }))),
          RestAccessPoint("api"),
          RouteBase("doc",
              handleUnknownAsRoot: true,
              root:
                  ContentDelivery("D:\\style\\packages\\style\\source\\web\\")),
          MethodFilterGate(
              allowedMethods: [Methods.GET],
              child: AuthFilterGate(
                  authRequired: true,
                  child: RouteBase("auth", root: AuthEnd()))),
          RouteBase("un-auth", root: CallQueue(UnAuthEnd())),
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
    return RouteBase("user",
        handleUnknownAsRoot: true,
        child: SubRoute("{api_key}",
            root: GeneratedRedirect(generate: (req) async {
          if (req.path.arguments["api_key"] == "v1") {
            return "../../auth";
          } else if (req.path.arguments["api_key"] == "v2") {
            return "../../un-auth";
          }
          return "*unknown";
        })),
        root: AuthRedirect(authorized: "../auth", unauthorized: "../un-auth"));
  }
}

class UnAuthEnd extends Endpoint {
  @override
  FutureOr<Message> onCall(Request request) async {
    try {
      print("Cevap Gitti UN: ${context.dataAccess}");
      return request.response({"args": "FROM UNAUTH"});
    } on Exception catch (e) {
      print("ON 2 $e");
      rethrow;
    }
  }
}

class AuthEnd extends Endpoint {
  @override
  FutureOr<Message> onCall(Request request) {
    return request.response({"args": "FROM AUTH"});
  }
}

class Post extends StatelessComponent {
  const Post({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) {
    return RouteBase("{post_id}",
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
    return request.response({"args": request.path.arguments});
  }
}

class MyUserEndpoint extends Endpoint {
  @override
  FutureOr<Message> onCall(Request request) {
    return request.response({"args": "FROM LANG"});
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
