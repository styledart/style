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

part of '../../style_base.dart';

///
abstract class HttpService extends BaseService {
  ///
  HttpService();

  ///
  static HttpService of(BuildContext context) => context.httpService;

  ///
  String get address;

  ///
  SecurityContext? securityContext;

  ///
  Map<String, dynamic>? get defaultResponseHeaders;

  ///
  Future<void> handleHttpRequest(HttpRequest request);

// @override
// Future<bool> init() async {
//   // await context.logger.ensureInitialize();
//   server = await serverBind;
//   if (defaultResponseHeaders != null) {
//     for (var h in defaultResponseHeaders!.entries) {
//       server.defaultResponseHeaders.add(h.key, h.value);
//     }
//   }
//   server.listen(handleHttpRequest);
//   return true;
// }
}

///
class DefaultHttpServiceHandler extends HttpService {
  ///
  DefaultHttpServiceHandler({String? host, int? port})
      : _address =
            host ?? String.fromEnvironment('HOST', defaultValue: 'localhost'),
        port = port ?? int.fromEnvironment('PORT', defaultValue: 80);

  ///
  final String _address;

  ///
  int port;

  ///
  @override
  Future<void> handleHttpRequest(HttpRequest request) async {
    var bodyBytes = await request.toList();
    var uInt8List = mergeList(bodyBytes);

    Object? body;
    if (uInt8List.isEmpty) {
      body = null;
    } else if (request.headers.contentType?.mimeType ==
        ContentType.json.mimeType) {
      try {
        body = json.decode(utf8.decode(uInt8List));
      } on Exception {
        body = null;
      }
    } else if (request.headers.contentType?.mimeType ==
            ContentType.html.mimeType ||
        request.headers.contentType == ContentType.text) {
      try {
        body = utf8.decode(uInt8List);
      } on Exception {
        body = null;
      }
    } else if (request.headers.contentType?.mimeType ==
        ContentType.binary.mimeType) {
      try {
        body = (uInt8List);
      } on Exception {
        body = null;
      }
    } else {
      try {
        body = json.decode(utf8.decode(uInt8List));
      } on Exception {
        try {
          body = utf8.decode(uInt8List);
        } on Exception {
          try {
            body = (uInt8List);
          } on Exception {
            body = null;
          }
        }
      }
    }

    var req = await HttpStyleRequest.fromRequest(
        req: request, body: Body(body), context: context);

    try {
      var res = await context.owner.calling(req);
      if (res is Response && res is! NoResponseRequired) {
        request.response.statusCode = res.statusCode;

        request.response.headers.contentType = res.contentType;
        for (var head in res.additionalHeaders?.entries.toList() ??
            <MapEntry<String, dynamic>>[]) {
          request.response.headers.add(head.key, head.value as Object);
        }

        if (res.body != null && res.body is StreamBody) {
          await request.response
              .addStream((res.body as StreamBody).streamBytes);
        } else if (res.body != null && res.body is BinaryBody) {
          request.response.add((res.body as BinaryBody).data);
        } else {
          if (res.body?.data != null) {
            request.response.write(res.body);
          }
        }

        await request.response.close();
        res.sent = true;
      }
    } on Exception catch (e) {
      request.response.statusCode = 400;
      request.response.headers.contentType = ContentType.json;
      request.response.write(json.encode({'error': e.toString()}));
      await request.response.close();
    }

    return;
  }

  @override
  Map<String, dynamic>? get defaultResponseHeaders => {};

  @override
  String get address => 'http://$_address:$port';

  ///
  Future<HttpServer> get serverBind => HttpServer.bind(_address, port);

  ///
  late HttpServer server;

  @override
  FutureOr<bool> init() async {
    // await context.logger.ensureInitialize();
    server = await serverBind;
    if (defaultResponseHeaders != null) {
      for (var h in defaultResponseHeaders!.entries) {
        server.defaultResponseHeaders.add(h.key, h.value as Object);
      }
    }
    server.listen(handleHttpRequest);
    return true;
  }
}
