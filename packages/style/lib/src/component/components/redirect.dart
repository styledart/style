part of '../../style_base.dart';

///
class Redirect extends Endpoint {
  ///
  Redirect(this.path);

  ///
  final String? path;

  ///
  static FutureOr<Message> redirect(
      {required Request request,
      required String? path,
      required BuildContext context}) async {
    if (path == null) {
      return context.unknown.call(request);
    }

    var uri = Uri.parse(path);

    if (uri.hasScheme) {
      if (uri.scheme.startsWith("http")) {
        if (request is HttpStyleRequest) {
          var uriString = uri.toString();
          var regex = RegExp(r"%7B([^}]*)%7D");
          if (regex.hasMatch(uriString)) {
            uriString = uriString.replaceAllMapped(regex, (match) {
              var matched = uriString.substring(match.start, match.end);
              matched = matched.substring(3, matched.length - 3);
              return request.path.arguments[matched] ?? "null";
            });
          }

          request.baseRequest.response
            ..statusCode = 301
            ..headers.add("Location", uriString)
            ..close();
          return NoResponseRequired(request: request);
        } else {
          //var req = await HttpClient().getUrl(uri);
          //var res = await req.close();
          //var resBodyList = await res.toList();
          //var resBodyBinary = mergeList(resBodyList as List<Uint8List>);
          //var resBody = utf8.decode(resBodyBinary);
          throw "un";
        }
      } else {
        throw "un";
      }
    } else {
      var segments = List<String>.from(uri.pathSegments);

      if (segments.first != "..") {
        var service = context.findAncestorServiceByName(segments.first);
        if (service == null) {
          throw "Service Not Found";
        }
        segments.removeAt(0);
        request.path.notProcessedValues.addAll(segments);
        request.path.current = segments.first;
        return service.call(request);
      }

      var nBinding = context;
      while (segments.first == "..") {
        var n = nBinding.findAncestorBindingOfType<GatewayBinding>();
        var s = nBinding.findAncestorBindingOfType<ServiceBinding>();

        print(n);
        print(s);

        if (n == null && s == null) {
          throw Exception("Path No Found"
              " : ${request.path.current} in ${nBinding.component}");
        }
        nBinding = n as GatewayBinding;
        segments.removeAt(0);
      }
      request.path.notProcessedValues.addAll(segments);
      request.path.current = segments.first;
      return ((nBinding).findAncestorBindingOfType<RouteBinding>() ??
              nBinding.findAncestorBindingOfType<ServiceBinding>()!)
          .call(request);
    }
  }

  @override
  FutureOr<Message> onCall(Request request) {
    return redirect(request: request, path: path, context: context);
  }
}

///
class GeneratedRedirect extends Endpoint {
  ///
  GeneratedRedirect({required this.generate});

  ///
  final Future<String?> Function(Request request) generate;

  @override
  FutureOr<Message> onCall(Request request) async {
    var uri = await generate(request);
    return Redirect.redirect(request: request, path: uri, context: context);
  }
}

///
class AuthRedirect extends StatelessComponent {
  ///
  const AuthRedirect(
      {Key? key, required this.authorized, required this.unauthorized})
      : super(key: key);

  ///
  final String authorized, unauthorized;

  @override
  Component build(BuildContext context) {
    return GeneratedRedirect(generate: (req) async {
      if (req.context.accessToken != null) {
        return authorized;
      } else {
        return unauthorized;
      }
    });
  }
}
