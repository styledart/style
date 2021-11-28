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
  Component component(BuildContext context);

  /// WebSocket connections by client identifier
  HashMap<String, WebSocketConnection> connections = HashMap();
}

///
abstract class StyleWebSocketService extends WebSocketService {
  ///
  factory StyleWebSocketService({bool allowOnlyAuth = true}) {
    if (allowOnlyAuth) {
      return AuthWebSocketService();
    }
    return _StyleWebSocketService();
  }

  ///
  Future<WebSocketConnection> connect(HttpRequest request,
      [WebSocketConnectionRequest? connectionRequest]);

  StyleWebSocketService._();
}

class _StyleWebSocketService extends StyleWebSocketService {
  _StyleWebSocketService() : super._();

  @override
  Component component(BuildContext context) {
    return Gateway(children: [Route("ws")]);
  }

  @override
  Future<WebSocketConnection> connect(HttpRequest request,
      [WebSocketConnectionRequest? connectionRequest]) async {
    var socket = await WebSocketTransformer.upgrade(request);
    return WebSocketConnection(
        socket: socket, id: request.connectionInfo!.remoteAddress.host);
  }
}

///
class AuthWebSocketService extends StyleWebSocketService {
  ///
  AuthWebSocketService() : super._();

  /// WebSocket connection requests(tickets) by client identifier.
  HashMap<String, WebSocketConnectionRequest> connectionTickets = HashMap();

  @override
  Component component(BuildContext context) {
    return Gateway(children: [
      Route("ws", root: SimpleEndpoint(_ws)),
      Route("ws_req", root: SimpleEndpoint(_wsRequest))
    ]);
  }

  FutureOr<Object> _wsRequest(Request request, BuildContext context) async {
    try {
      var token = request.token;

      if (token == null) {
        throw UnauthorizedException();
      }

      var id = getRandomId(40);
      var ticket = WebSocketConnectionRequest(
          token: token,
          id: id,
          onTimeout: () {
            connectionTickets.remove(id);
          });

      connectionTickets[id] = ticket;

      return request.response(Body({"ticket": ticket.id}));
    } on Exception {
      rethrow;
    }
  }

  FutureOr<Object> _ws(Request request, BuildContext context) async {
    try {
      var id = request.path.queryParameters["id"];
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

      if (connection.connected) {
        return {"connection_time": DateTime.now().millisecondsSinceEpoch};
      }

      throw BadRequests();
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<WebSocketConnection> connect(HttpRequest request,
      [WebSocketConnectionRequest? connectionRequest]) async {
    if (connectionRequest == null) {
      throw UnauthorizedException();
    }

    var socket = await WebSocketTransformer.upgrade(request);

    return WebSocketConnection(
        socket: socket,
        id: request.connectionInfo!.remoteAddress.host,
        token: connectionRequest.token);
  }
}

/// A web socket connection. Created at connected and disposed
/// at connection end.
class WebSocketConnection {
  ///
  WebSocketConnection({required this.id, required this.socket, this.token});

  ///
  WebSocket socket;

  ///
  AccessToken? token;

  ///
  bool get connected => socket.closeCode == null;

  ///
  String id;
}

///
class WebSocketConnectionRequest {
  ///
  WebSocketConnectionRequest(
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
