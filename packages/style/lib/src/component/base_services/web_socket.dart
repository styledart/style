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
abstract class WebSocketService extends _BaseService {
  ///
  static WebSocketService of(BuildContext context) {
    return context.socketService;
  }

  @override
  Future<bool> init([bool inInterface = true]) async {
    //TODO: check http server already attached a websocket service
    return true;
  }

  ///
  Component buildComponent(BuildContext context);

  /// WebSocket connections by client identifier
  HashMap<String, WebSocketConnection> connections = HashMap();
}

///
abstract class DefaultWebSocketService extends WebSocketService {
  ///
  factory DefaultWebSocketService({bool allowOnlyAuth = true}) {
    if (allowOnlyAuth) {
      return AuthWebSocketService();
    }
    return _StyleWebSocketService();
  }

  ///
  Future<WebSocketConnection> connect(HttpRequest request,
      [WebSocketConnectionTicket? connectionRequest]);

  DefaultWebSocketService._();
}

class _StyleWebSocketService extends DefaultWebSocketService {
  _StyleWebSocketService() : super._();

  @override
  Component buildComponent(BuildContext context) {
    return Gateway(children: [
      Route("ws", root: SimpleEndpoint((r, c) async {
        if (r is! HttpStyleRequest) {
          throw BadRequests();
        }
        var con = await connect(r.baseRequest);
        connections[con.id] = con;
        return NoResponseRequired(request: r);
      }))
    ]);
  }

  @override
  Future<WebSocketConnection> connect(HttpRequest request,
      [WebSocketConnectionTicket? connectionRequest]) async {
    var socket = await WebSocketTransformer.upgrade(request);
    return WebSocketConnection(
        socket: socket, context: context, id: getRandomId(40));
  }
}

///
class AuthWebSocketService extends DefaultWebSocketService {
  ///
  AuthWebSocketService() : super._();

  /// WebSocket connection requests(tickets) by client identifier.
  HashMap<String, WebSocketConnectionTicket> connectionTickets = HashMap();

  @override
  Component buildComponent(BuildContext context) {
    return Gateway(children: [
      Route("{id}", child: Route("ws", root: SimpleEndpoint(_ws))),
      Route("ticket_req", root: SimpleEndpoint(_ticketRequest))
    ]);
  }

  FutureOr<Object> _ticketRequest(Request request, BuildContext context) async {
    try {
      var token = request.token;

      if (token == null) {
        throw UnauthorizedException();
      }

      var id = getRandomId(40);
      var ticket = WebSocketConnectionTicket(
          token: token,
          id: id,
          onTimeout: () {
            connectionTickets.remove(id);
          });

      connectionTickets[id] = ticket;

      return request.response(Body({"t": ticket.id}));
    } on Exception {
      rethrow;
    }
  }

  FutureOr<Object> _ws(Request request, BuildContext context) async {
    try {
      var id = request.arguments["id"];
      if (id == null) {
        throw PreconditionFailed();
      }

      var ticket = connectionTickets[id];

      if (ticket == null) {
        return RequestTimeoutException();
      }

      var connection =
          await connect((request as HttpStyleRequest).baseRequest, ticket);

      connections[id] = connection;

      return NoResponseRequired(request: request);
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<WebSocketConnection> connect(HttpRequest request,
      [WebSocketConnectionTicket? connectionTicket]) async {
    if (connectionTicket == null) {
      throw UnauthorizedException();
    }

    var socket = await WebSocketTransformer.upgrade(request);

    return WebSocketConnection(
        socket: socket,
        context: context,
        id: request.connectionInfo!.remoteAddress.host,
        token: connectionTicket.token);
  }
}

/// A web socket connection. Created at connected and disposed
/// at connection end.
class WebSocketConnection {
  ///
  WebSocketConnection(
      {required this.id,
      required this.socket,
      this.token,
      required this.context}) {

    messages = socket.transform(
        StreamTransformer<dynamic, WebSocketMessage>.fromBind((s) async* {
      await for (var m in s) {}
    })).asBroadcastStream();
  }

  ///
  late WebSocketService service = WebSocketService.of(context);

  ///
  WebSocket socket;

  ///
  BuildContext context;

  ///
  AccessToken? token;

  ///
  late Stream<WebSocketMessage> messages;

  ///
  bool get connected => socket.closeCode == null;

  ///
  String id;

  ///
  void sendMessage(WebSocketMessage message) {
    try {
      socket.addUtf8Text(
          utf8.encode(json.encode((message.body as JsonBody).data)));
    } on Exception {
      rethrow;
    }
  }
}

///
class WebSocketConnectionTicket {
  ///
  WebSocketConnectionTicket(
      {required this.token,
      required this.id,
      Duration timeout = const Duration(seconds: 30),
      required void Function() onTimeout})
      : create = DateTime.now() {
    Timer(timeout, onTimeout);
  }

  ///
  AccessToken token;

  ///
  String id;

  ///
  DateTime create;
}
