part of '../../style_base.dart';

///
abstract class HttpServiceHandler extends _BaseService {
  ///
  HttpServiceHandler();

  ///
  String get address;

  ///
  SecurityContext? securityContext;

  ///
  Future<HttpServer> get serverBind;

  ///
  Map<String, dynamic>? get defaultResponseHeaders;

  ///
  late final HttpServer server;

  ///
  Future<void> handleHttpRequest(HttpRequest request);

  @override
  Future<bool> init([bool inInterface = true]) async {
    // await context.logger.ensureInitialize();
    if (!inInterface) {
      server = await serverBind;
      if (defaultResponseHeaders != null) {
        for (var h in defaultResponseHeaders!.entries) {
          server.defaultResponseHeaders.add(h.key, h.value);
        }
      }
    }
    if (!inInterface) {
      await for (HttpRequest request in server) {
        handleHttpRequest(request);
      }
    }
    return true;
  }
}

///
extension HttpHeadersMap on HttpHeaders {
  ///
  Map<String, dynamic> toMap() {
    var m = <String, List<String>>{};

    forEach((name, values) {
      m[name] = values;
    });

    return m;
  }
}

///
class DefaultHttpServiceHandler extends HttpServiceHandler {
  ///
  DefaultHttpServiceHandler()
      : _address = String.fromEnvironment("HOST", defaultValue: "localhost"),
        port = int.fromEnvironment("PORT", defaultValue: 80);

  ///
  final String _address;

  ///
  int port;

  ///
  Future<void> handleHttpRequest(HttpRequest request) async {
    var body = await request.toList();

    var uInt8List = mergeList(body);

    var _body;
    if (uInt8List.isEmpty) {
      _body = null;
    } else if (request.headers.contentType?.mimeType ==
        ContentType.json.mimeType) {
      try {
        _body = json.decode(utf8.decode(uInt8List));
      } on Exception {
        _body = null;
      }
    } else if (request.headers.contentType?.mimeType ==
            ContentType.html.mimeType ||
        request.headers.contentType == ContentType.text) {
      try {
        _body = utf8.decode(uInt8List);
      } on Exception {
        _body = null;
      }
    } else if (request.headers.contentType?.mimeType ==
        ContentType.binary.mimeType) {
      try {
        _body = (uInt8List);
      } on Exception {
        _body = null;
      }
    } else {
      try {
        _body = json.decode(utf8.decode(uInt8List));
      } on Exception {
        try {
          _body = utf8.decode(uInt8List);
        } on Exception {
          try {
            _body = (uInt8List);
          } on Exception {
            _body = null;
          }
        }
      }
    }

    var req = HttpStyleRequest.fromRequest(
        req: request, body: Body(_body), context: context);
    try {
      var res = await context.owner.calling(req);
      if (res is Response && res is! NoResponseRequired) {
        request.response.statusCode = res.statusCode;
        request.response.headers.contentType = res.contentType;

        for (var head in res.additionalHeaders?.entries.toList() ??
            <MapEntry<String, dynamic>>[]) {
          request.response.headers.add(head.key, head.value);
        }
        if (res.body != null && res.contentType == ContentType.binary) {
          request.response.add((res.body as BinaryBody).data);
        } else if (res.body is! NullBody) {
          request.response.write(res.body);
        }

        await request.response.close();
        res.sent = true;
      }
    } on Exception catch (e) {
      print(e);
      // request.response.statusCode = 400;
      // request.response.headers.contentType = ContentType.json;
      // request.response.write(json.encode({"error": e.toString()}));
      // request.response.close();
    }

    return;
  }

  @override
  Map<String, dynamic>? get defaultResponseHeaders => {};

  @override
  String get address => "http://$_address:$port";

  @override
  Future<HttpServer> get serverBind => HttpServer.bind(_address, port);
}
