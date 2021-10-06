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
  Future<HttpServer> get serverLoader;

  ///
  Map<String, dynamic>? get defaultResponseHeaders;

  ///
  late final HttpServer server;

  ///
  Future<void> handleHttpRequest(HttpRequest request);

  late final Completer<bool> _listeningCompleter = Completer<bool>();

  ///
  Future<bool> ensureListening() async {
    return await _listeningCompleter.future;
  }

  ///
  @mustCallSuper
  Future<void> listenServer({bool inInterface = true}) async {
    if (!inInterface) {
      server = await serverLoader;
    }
    _listeningCompleter.complete(true);
    if (!inInterface) {
      await for (HttpRequest request in server) {
        handleHttpRequest(request);
      }
    }
  }

  @override
  Future<void> init() {
    return listenServer(inInterface: false);
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

  late final HttpServer server;

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
      var res = await context.owner.calling.onCall(req);
      if (res is Response && res is! NoResponseRequired) {
        request.response.statusCode = res.statusCode;
        request.response.headers.contentType = res.contentType;
        for (var head in res.additionalHeaders?.entries.toList() ??
            <MapEntry<String, dynamic>>[]) {
          request.response.headers.add(head.key, head.value);
        }
        if (res.body != null && res.contentType == ContentType.binary) {
          request.response.add((res.body as BinaryBody).data);
        } else {
          request.response.write(res.body);
        }

        await request.response.close();
        res.sent = true;
      }
    } on Exception catch (e) {
      request.response.statusCode = 400;
      request.response.headers.contentType = ContentType.json;
      request.response.write(json.encode({"error": e.toString()}));
      request.response.close();
    }

    return;
  }

  @override
  Map<String, dynamic>? get defaultResponseHeaders => {};

  @override
  String get address => "http://$_address:$port";

  @override
  Future<HttpServer> get serverLoader => HttpServer.bind(_address, port);
}
