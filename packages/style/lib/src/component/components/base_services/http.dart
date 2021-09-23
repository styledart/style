part of '../../../style_base.dart';

///
abstract class HttpServiceHandler extends _BaseService {
  //TODO:

  ///
  HttpServiceHandler({
    this.host = "localhost",
    this.port = 9090,
    this.secure = false,
  }) : server = io.HttpServer.bind(host, port);

  ///
  String get address => "${secure ? "https" : "http"}://$host:$port";

  ///
  String host;

  ///
  int port;

  ///
  bool secure;

  ///
  late final BuildContext context;

  ///
  Future<io.HttpServer> server;

  ///
  Future<void> listenServer();
}

///
const Map<String, dynamic> _defaultHeaders = {
  "Access-Control-Allow-Origin": '*',
  'Access-Control-Allow-Credentials': 'true',
  'Access-Control-Allow-Headers': '*',
  'Access-Control-Allow-Methods': 'GET,POST,PUT,OPTIONS,DELETE,UPDATE',
};

///
class DefaultHttpServiceHandler extends HttpServiceHandler {
  late final io.HttpServer _server;

  @override
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

  ///
  Future<void> handleHttpRequest(io.HttpRequest request) async {
    print("req handle : $request");

    print(context);
    print(context.owner);
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
        req: request, json: jsonMap ?? {}, context: context);
    print("Req created: $req");
    var res =await context.owner.call(req);
    request.response.headers.contentType = io.ContentType.json;
    request.response.write(json.encode(res.body));
    request.response.close();
    return;
  }

  @override
  Future<void> init() {
    return listenServer();
  }
}
