part of '../../../style_base.dart';

///
abstract class HttpServiceHandler extends _BaseService {
  ///
  HttpServiceHandler();

  ///
  String get address;

  ///
  io.SecurityContext? securityContext;

  ///
  late final BuildContext context;

  ///
  Future<io.HttpServer> get server;

  ///
  Map<String, dynamic>? get defaultResponseHeaders;

  late final io.HttpServer _server;

  ///
  Future<void> handleHttpRequest(io.HttpRequest request);

  ///
  Future<void> listenServer() async {
    _server = await server;
    // _addHeaders();
    // Logger().important("server_start",
    //     title:
    //     "HTTP SERVER LISTENING ON: ${_server.address}:${_server.port}");
    //

    await for (io.HttpRequest request in _server) {
      handleHttpRequest(request);
    }
  }

  @override
  Future<void> init() {
    return listenServer();
  }
}

///
class DefaultHttpServiceHandler extends HttpServiceHandler {
  ///
  DefaultHttpServiceHandler({String address = "localhost", this.port = 10500})
      : _address = address;

  ///
  final String _address;

  ///
  int port;

  late final io.HttpServer _server;

  ///
  Future<void> handleHttpRequest(io.HttpRequest request) async {
    var body = await request.toList();
    var uInt8List = mergeList(body);
    Map<String, dynamic>? jsonMap;
    if (request.headers.contentType?.mimeType == io.ContentType.json.mimeType) {
      try {
        jsonMap = json.decode(utf8.decode(uInt8List));
      } on Exception {
        jsonMap = null;
        return;
      }
    }
    var req = HttpRequest.fromRequest(
        req: request, body: jsonMap ?? {}, context: context);
    var res = await context.owner.call(req);
    request.response.headers.contentType = io.ContentType.json;
    request.response.write(json.encode(res.body));
    request.response.close();
    return;
  }

  @override
  Map<String, dynamic>? get defaultResponseHeaders => {};

  @override
  String get address => "$_address:$port";

  @override
  Future<io.HttpServer> get server => io.HttpServer.bind(_address, port);
}
