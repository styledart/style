/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE,
 *    Version 3 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       https://www.gnu.org/licenses/agpl-3.0.en.html
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

part of '../../style_base.dart';

///
class Redirect extends Endpoint {
  ///
  Redirect(this.path);

  ///
  final String path;

  ///
  static FutureOr<Message> redirect(
      {required Request request,
      required String path,
      required BuildContext context}) async {
    var uri = Uri.parse(path);

    if (uri.hasScheme) {
      if (uri.scheme.startsWith('http')) {
        if (request is HttpStyleRequest) {
          var uriString = uri.toString();
          var regex = RegExp(r'%7B([^}]*)%7D');
          if (regex.hasMatch(uriString)) {
            uriString = uriString.replaceAllMapped(regex, (match) {
              var matched = uriString.substring(match.start, match.end);
              matched = matched.substring(3, matched.length - 3);
              return request.path.arguments[matched] ?? 'null';
            });
          }

          request.baseRequest.response
            ..statusCode = 301
            ..headers.add('Location', uriString);

          await request.baseRequest.response.close();

          return NoResponseRequired(request: request);
        } else {
          //var req = await HttpClient().getUrl(uri);
          //var res = await req.close();
          //var resBodyList = await res.toList();
          //var resBodyBinary = mergeList(resBodyList as List<Uint8List>);
          //var resBody = utf8.decode(resBodyBinary);
          throw 'un';
        }
      } else {
        throw 'un';
      }
    } else {
      var segments = List<String>.from(uri.pathSegments);

      if (segments.first != '..') {
        var service = context.findAncestorServiceByName(segments.first);
        if (service == null) {
          throw 'Service Not Found';
        }
        segments.removeAt(0);
        request.path.notProcessedValues.addAll(segments);
        request.path.next = segments.first;
        return service.calling(request);
      }

      var nBinding = context;
      while (segments.first == '..') {
        var n = nBinding.findAncestorBindingOfType<GatewayBinding>();
        var s = nBinding.findAncestorBindingOfType<ServerBinding>();
        if (n == null && s == null) {
          throw Exception('Path No Found'
              ' : ${request.path.next} in ${nBinding.component}');
        }
        nBinding = n as GatewayBinding;
        segments.removeAt(0);
      }
      request.path.notProcessedValues.addAll(segments);
      request.path.next = segments.first;

      return ((nBinding).findAncestorBindingOfType<RouteBinding>() ??
              nBinding.findAncestorBindingOfType<ServerBinding>()!)
          .calling(request);
    }
  }

  @override
  FutureOr<Message> onCall(Request request) => redirect(request: request, path: path, context: context);
}

///
class GeneratedRedirect extends Endpoint {
  ///
  GeneratedRedirect({required this.generate});

  ///
  final FutureOr<String> Function(Request request) generate;

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
  Component build(BuildContext context) => GeneratedRedirect(generate: (req) async {
      if (req.context.accessToken != null) {
        return authorized;
      } else {
        return unauthorized;
      }
    });
}
