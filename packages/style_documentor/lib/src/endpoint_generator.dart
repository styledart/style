import 'package:style_documentor/src/generated.dart';

class GeneratedEndpoint {
  GeneratedEndpoint(this.isRedirect, this.className, this.full);

  String className;

  String full;

  bool isRedirect;

  static generateFor(String data) {
    if (data.contains(".") || data.contains("/")) {
      return GeneratedEndpoint(true, "", "Redirect('$data')");
    } else {
      var end = """


class ${toClassName(data)} extends Endpoint {

  @override
  FutureOr<Message> onCall(Request request) {
    // TODO: implement onCall
    throw UnimplementedError();
  }
}


      """;

      return GeneratedEndpoint(false, toClassName(data), end);
    }
  }
}
