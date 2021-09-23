import 'dart:async';

import 'package:style/style.dart';

void main() {
  runService(BerberServer());
}

class BerberServer extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Server(
      rootName: "berber_server",
      defaultUnknownEndpoint: BerberUnknownRequest(),
      rootEndpoint: Redirect('../home'),
      children: [
        // TODO: 
      ],
    );
  }
}



class BerberUnknownRequest extends Endpoint {

  @override
  FutureOr<Message> onCall(Request request) {
    // TODO: implement onCall
    throw UnimplementedError();
  }
}


      
