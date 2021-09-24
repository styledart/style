import 'dart:async';

import 'package:style/style.dart';

/// Bu App Güzel Çalışacak
void main() {
  runService(MyServer());
}

///
class MyServer extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Server(
        rootName: "my_server",
        children: [
          Route(segment: "favicon.ico", root: UnknownEndpoint()),
          Route(
              segment: "post",
              child: Post(),
              root: SimpleEndpoint((req) async {
                return req.createJsonResponse({"path": "post_root"});
              })),
          Route(
              segment: "{user}",
              child: User(),
              root: SimpleEndpoint((req) async {
                return req.createJsonResponse({"path": "user/*root"});
              }))
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
    return RouteTo(
        handleUnknownAsRoot: true, segment: "lang", root: MyUserEndpoint());
  }
}

class Post extends StatelessComponent {
  const Post({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) {
    return RouteTo(segment: "{post_id}", root: PostEnd());
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
    return request.createJsonResponse({"args": request.path.arguments});
  }
}
