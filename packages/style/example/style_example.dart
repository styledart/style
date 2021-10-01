import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:stack_trace/stack_trace.dart';
import 'package:style/src/functions/random.dart';
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
        children: [
          Post(),
          User(),
          Route("api", root: SimpleAccessPoint(), handleUnknownAsRoot: true),
          Route("doc",
              handleUnknownAsRoot: true,
              root: DocumentService("D:\\style\\packages\\style\\source\\",
                  cacheAll: false)),

          AuthFilterGate(
              authRequired: true,
              child: Route("auth", root: AuthEnd())),


          Route("un-auth", root: UnAuthEnd()),
          Route("favicon.ico", root: Favicon()),
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
  FutureOr<Message> onCall(Request request) {
    return request.createJsonResponse({"args": "FROM UNAUTH"});
  }
}

class AuthEnd extends Endpoint {
  @override
  FutureOr<Message> onCall(Request request) {
    return request.createJsonResponse({"args": "FROM AUTH"});
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
    return request.createJsonResponse({"args": request.path.arguments});
  }
}

class MyUserEndpoint extends Endpoint {
  @override
  FutureOr<Message> onCall(Request request) {
    return request.createJsonResponse({"args": "FROM LANG"});
  }
}

class Favicon extends StatefulEndpoint {
  @override
  EndpointState createState() => FaviconState();
}

///
class FaviconState extends EndpointState<Favicon> {
  Uint8List? data;
  late Future<void> dataLoader;
  String? tag;

  ///
  Future<void> _loadIcon() async {
    var entities = <FileSystemEntity>[
      Directory("D:\\style\\packages\\style\\source")
    ];

    while (entities.isNotEmpty) {
      for (var en in List.from(entities)) {
        if (en is Directory) {
          entities.addAll(en.listSync());
          print("Dir: $en");
        } else {
          print("Fil: $en");
        }
        entities.removeAt(0);
      }
    }

    var file = File("D:\\style\\packages\\style\\assets\\favicon.ico");
    data = await file.readAsBytes();
    tag = getRandomId(5);
  }

  void listenFileChanges() {
    File("D:\\style\\packages\\style\\assets\\favicon.ico")
        .watch()
        .listen((event) {
      data = null;
      dataLoader = _loadIcon();
    });
  }

  @override
  void initState() {
    dataLoader = _loadIcon();
    listenFileChanges();
    super.initState();
  }

  @override
  FutureOr<Message> onCall(Request request) async {
    var base = (request as HttpRequest).baseRequest;

    if (base.headers["if-none-match"] != null &&
        base.headers["if-none-match"] == tag) {
      base.response.statusCode = 304;
      base.response.contentLength = 0;
      base.response.close();
      return NoResponseRequired(request: request);
    }

    if (data == null) {
      await dataLoader;
    }

    base.response.contentLength = data!.length;
    base.response.headers
      ..add(HttpHeaders.contentTypeHeader, ContentType.binary.mimeType)
      ..add(HttpHeaders.cacheControlHeader, "must-revalidate")
      ..add(HttpHeaders.etagHeader, tag!);
    base.response.add(data!);
    base.response.close();
    return NoResponseRequired(request: request);
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
