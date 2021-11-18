import 'dart:async';
import 'dart:io';

import 'package:style_dart/style_dart.dart';

///
class RouteExample extends StatelessComponent {
  ///
  const RouteExample({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) {
    return Server(
        children: [
      Route("a",
          child: Gateway(children: [
            Route("1",
                root: SimpleEndpoint.static("1r"),
                child: Gateway(children: [
                  Route("11", root: SimpleEndpoint.static("11")),
                  Route("12", root: SimpleEndpoint.static("12"))
                ])),
            Route("2",
                root: SimpleEndpoint.static("2r"),
                child: Route("21", root: SimpleEndpoint.static("21")))
          ])),
      Gate(
          child: Gateway(children: [
            Gate(
                child: Route("3",
                    root: SimpleEndpoint.static("3r"),
                    child: Gate(
                        child: Route("31", root: SimpleEndpoint.static("31")),
                        onRequest: (r) {
                          print("only 31");
                          return r;
                        })),
                onRequest: (r) {
                  print("only 3");
                  return r;
                }),
            Route("4",
                root: SimpleEndpoint.static("4r"),
                child: Route("41", root: SimpleEndpoint.static("41")))
          ]),
          onRequest: (r) {
            print("3 ve 4");
            return r;
          }),
      Gateway(children: [
        Gate(
            child: Route("5",
                root: SimpleEndpoint.static("5r"),
                child: Route("51", root: SimpleEndpoint.static("51"))),
            onRequest: (r) {
              print("path 5");
              return r;
            }),
        Route("6",
            root: SimpleEndpoint.static("6r"),
            child: Route("61",
                root: Gate(
                    child: SimpleEndpoint.static("61"),
                    onRequest: (r) {
                      print("Path 61");
                      return r;
                    })))
      ])
    ]);
  }
}

///
class MyServer extends StatelessComponent {
  /// The key for identify component.
  ///
  /// The monitoring app use this key.
  /// Also cli app use keys on "set-property" command.
  const MyServer({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) {
    return Server(

        // Project root name for using in redirect
        // or reach microservices
        rootName: "simple",

        // Root Endpoint handle http(s)://<host> requests
        // You can use redirect for your default endpoint
        // eg. Redirect("../index.html")
        // for redirecting documentation (temporary)http..://google.com
        // call http://localhost
        rootEndpoint: SimpleEndpoint.static("Hello World!"),
        httpService: DefaultHttpServiceHandler(port: 180),

        // you can change favicon.ico
        faviconDirectory: "D:/style/packages/style/examples/simple/assets/",

        // Server routes
        children: [
          WebDev(
              buildInitialize: true,
              watchChanges: true,
              projectDirectory:
                  "D:\\style\\packages\\style\\examples\\simple\\"),

          /// Route and sub-route http(s)://localhost/hi(/..)
          HelloComponent(),

          /// [SimpleEndpoint] create a endpoint with callback
          Route("style", root: SimpleEndpoint((req, ctx) {
            /// You can response directly with body.
            /// Also you can response with custom properties (eg status code)
            return req.response(Body("is very good"),
                statusCode: 202,
                contentType: ContentType.text,
                headers: {"x-my_head": "header"});
          })),

          /// Sum 40 and 2 : http://localhost/sum/40/2
          MathOperationRoute("sum", (a, b) => a + b),

          /// Difference 44 and 2 : http://localhost/dif/44/2
          MathOperationRoute("dif", (a, b) => a - b),
        ]);
  }
}

/// The component for creating state
class HelloComponent extends StatefulComponent {
  /// The global keys using for reaching the state anywhere.
  /// States stored on context's service owner
  HelloComponent()
      : super(key: GlobalKey<HelloComponentState>("hello_component"));

  @override
  HelloComponentState createState() => HelloComponentState();
}

/// The state stored our some states
class HelloComponentState extends State<HelloComponent> {
  ///
  int helloCount = 0;

  @override
  void initState() {
    helloCount = 0;
    super.initState();
  }

  ///
  Object helloEveryone(Request request, BuildContext context) {
    return "Hello Everyone! $helloCount";
  }

  @override
  Component build(BuildContext context) {
    return Route("hi",

        /// Say hello everyone http://localhost/hi
        root: SimpleEndpoint(helloEveryone),

        /// Say hi http://localhost/hi/mehmet
        child: Route("{name}",

            /// Queue call. I cannot greet more than one
            /// person at the same time.
            root: CallQueue(SayHello())));
  }
}

///
class SayHello extends Endpoint {
  ///
  SayHello() : super();

  @override
  FutureOr<Object> onCall(Request request) async {
    /// Get state
    /// You can also find it with [context.findAncestorStateOfKey]
    var state = context.findAncestorStateOfType<HelloComponentState>();

    await Future.delayed(Duration(seconds: 3));
    state!.helloCount++;
    return "Hello ${request.arguments["name"]}! "
        "This is my ${state.helloCount}. saying";
  }
}

///
class MathOperationRoute extends StatelessComponent {
  ///
  MathOperationRoute(this.name, this.operation);

  /// Operation route.
  /// eg when name is "sum".
  /// http(s)://host/sum/.. handled
  final String name;

  /// Math operation with 2 input
  final num Function(int a, int b) operation;

  @override
  Component build(BuildContext context) {
    return ExceptionWrapper(
        child: Route(name,

            /// on called http(s)://host/{name}
            /// so we cant calculate anything
            root: Throw(FormatException()),

            /// Handle "http(s)://host/" 's sub-routes with argument as "a"
            child: Route("{a}",

                /// on called http(s)://host/{name}/{a}
                /// also we cant calculate anything with only one input
                root: Throw(FormatException()),
                child: Route("{b}",

                    /// on called http(s)://host/{name}/{a}/{b}
                    /// now, we can calculate
                    root: SimpleEndpoint((request, _) {
                  var a = int.parse(request.arguments["a"]);
                  var b = int.parse(request.arguments["b"]);
                  return {"a": a, "b": b, name: operation(a, b)};
                })))),
        exceptionEndpoint: FormatExceptionEndpoint());
  }
}

///
class FormatExceptionEndpoint extends ExceptionEndpoint<FormatException> {
  @override
  FutureOr<Object> onError(
      Message message, FormatException exception, StackTrace stackTrace) {
    return "please ensure path like: \"host/{sum|div|dif|mul}/{number}/{number}\"";
  }
}
