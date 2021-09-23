
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
          PathRouter(
              segment: "user",
              child: User(),
              handleUnknownAsRoot: true,
              root: SimpleEndpoint((req) async {
                return req.createResponse({"path": "user_root"});
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
    return UnknownEndpoint();
  }
}
