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
abstract class WebSocketService extends BaseService {
  ///
  WebSocketService(
      {RandomGenerator? connectionIdGenerator,
      RandomGenerator? messageIdGenerator,
      required WebSocketMessageTransformer messageTransformer})
      : connectionIdGenerator =
            connectionIdGenerator ?? RandomGenerator('[*#]/l(20)'),
        messageIdGenerator = messageIdGenerator ?? RandomGenerator('./l(30)'),
        _messageTransformer = messageTransformer;

  ///
  static WebSocketService of(BuildContext context) => context.socketService;

  ///
  final WebSocketMessageTransformer _messageTransformer;

  ///
  final RandomGenerator connectionIdGenerator;

  ///
  final RandomGenerator messageIdGenerator;

  @override
  Future<bool> init([bool inInterface = true]) async {
    if (!context.hasService<HttpService>()) {
      throw ArgumentError('WebSocket service need HttpService');
    }
    if (!context.hasService<Crypto>()) {
      throw ArgumentError('WebSocket service need Crypto');
    }
    return true;
  }

  ///
  Component component(BuildContext context);

  /// WebSocket connections by client identifier
  HashMap<String, WebSocketConnection> connections = HashMap();

  ///
  HashMap<String, HashSet<String>> authorizedConnections = HashMap();

  ///
  void addConnection(WebSocketConnection connection) {
    connections[connection.id] = connection;
    if (connection.token != null) {
      authorizedConnections[connection.token!.userId] ??=
          HashSet.from(<String>{});
      authorizedConnections[connection.token!.userId]!.add(connection.id);
    }
  }

  ///
  void removeConnection(String id) {
    if (connections[id] == null) {
      return;
    }
    var token = connections[id]?.token;
    if (token != null) {
      authorizedConnections[token.userId]?.remove(id);
      if (authorizedConnections[token.userId]?.isEmpty ?? true) {
        authorizedConnections.remove(token.userId);
      }
    }
    connections.remove(id);
  }

  /// Set connection authorize status.
  ///
  /// If token isn't null connection identifier will
  /// add to [authorizedConnections] and connection
  /// auth status will switch to auth.
  ///
  ///
  /// If token is null connection will remove from [authorizedConnections]
  /// and connection status switch to un-auth.
  ///
  /// If switched to un-auth and WebSocketService need auth connection disposed
  void setConnectionAuthorize(
      {required String connectionId,
      required AccessToken token,
      required bool setAuth}) {
    if (setAuth) {
      authorizedConnections[token.userId] ??= HashSet<String>();
      authorizedConnections[token.userId]?.add(token.userId);
    } else {
      authorizedConnections[token.userId]?.remove(connectionId);
      if (authorizedConnections[token.userId]?.isEmpty ?? false) {
        authorizedConnections.remove(token.userId);
      }
    }
  }

  void onCall(WebSocketMessage event) async {
    var res =
        (await context.owner.calling(event as WebSocketRequest)) as Response;

    if (res.body is StreamBody) {
      (res.body as StreamBody).stream.listen((e) {
        event.connection._outgoingController.sink.add(WebSocketResponse(
            id: event.id,
            connection: event.connection,
            body: Body(e),
            statusCode: res.statusCode,
            request: event));
      });
      return;
    }

    event.connection._outgoingController.sink.add(WebSocketResponse(
        id: event.id,
        connection: event.connection,
        body: res.body,
        statusCode: res.statusCode,
        request: event));
    return;
  }

// Stream<WebSocketMessage> _transformMessage(Stream messageStream) async* {
//   await for (var message in messageStream) {
//     try {
//       FutureOr<WebSocketMessage> _converting;
//       if (message is String) {
//         _converting = convertIncomingMessage(message);
//       } else {
//         _converting = convertIncomingMessage(utf8.decode(message));
//       }
//       if (_converting is Future) {
//         (_converting as Future).timeout(Duration(seconds: 20));
//       }
//     } on Exception {
//       //TODO: Log
//     }
//   }
// }

}

///
abstract class StyleWebSocketService extends WebSocketService {
  ///
  factory StyleWebSocketService({bool allowOnlyAuth = true}) {
    if (allowOnlyAuth) {
      return TicketWebSocketService();
    }
    return BasicWebSocketService();
  }

  ///
  Future<WebSocketConnection> connect(HttpRequest request,
      [WebSocketConnectionRequest? connectionRequest]);

  StyleWebSocketService._()
      : super(messageTransformer: DefaultWSMessageTransformer());
}

///
class BasicWebSocketService extends StyleWebSocketService {
  ///
  BasicWebSocketService() : super._();

  @override
  Component component(BuildContext context) => Gateway(children: [
        Route('ws', handleUnknownAsRoot: true, root: SimpleEndpoint(_ws))
      ]);

  FutureOr<Object> _ws(Request request, BuildContext context) async {
    try {
      var connection = await connect((request as HttpStyleRequest).baseRequest);

      if (connection.connected) {
        addConnection(connection);
        return NoResponseRequired(request: request);
      }
      throw BadRequests();
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<WebSocketConnection> connect(HttpRequest request,
      [WebSocketConnectionRequest? connectionRequest]) async {
    var socket = await WebSocketTransformer.upgrade(request);
    return WebSocketConnection(
        socket: socket,
        id: connectionIdGenerator.generateString(),
        webSocketService: this);
  }
}

///
class TicketWebSocketService extends StyleWebSocketService {
  ///
  TicketWebSocketService({Authorization? customAuthorization})
      : _authorization = customAuthorization,
        super._();

  ///
  Authorization get authorization => _authorization!;

  ///
  Authorization? _authorization;

  /// WebSocket connection requests(tickets) by client identifier.
  HashMap<String, WebSocketConnectionRequest> connectionTickets = HashMap();

  @override
  Future<bool> init([bool inInterface = true]) {
    if (!context.hasService<Authorization>()) {
      throw ArgumentError('Ticket based websocket service require'
          'auth service');
    }
    _authorization ??= context.authorization;
    return super.init(inInterface);
  }

  @override
  Component component(BuildContext context) => Gateway(children: [
        Route('ws', root: SimpleEndpoint(_ws)),
        Route('ws_req', root: SimpleEndpoint(_wsRequest))
      ]);

  FutureOr<Object> _wsRequest(Request request, BuildContext context) async {
    try {
      try {
        await request.verifyTokenWith(authorization);
      } on Exception {
        rethrow;
      }

      var id = connectionIdGenerator.generateString();
      var ticket = WebSocketConnectionRequest(
          token: request.token!,
          id: id,
          onTimeout: () {
            connectionTickets.remove(id);
          });

      connectionTickets[id] = ticket;

      return request.response(Body({'ticket': ticket.id}));
    } on Exception {
      rethrow;
    }
  }

  FutureOr<Object> _ws(Request request, BuildContext context) async {
    try {
      var id = request.path.queryParameters['id'];
      if (id == null) {
        throw PreconditionFailed();
      }

      var ticket = connectionTickets[id];

      if (ticket == null) {
        return RequestTimeoutException();
      }

      var connection =
          await connect((request as HttpStyleRequest).baseRequest, ticket);

      addConnection(connection);

      return NoResponseRequired(request: request);
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
        token: connectionRequest.token,
        webSocketService: this);
  }
}

/// A web socket connection. Created at connected and disposed
/// at connection end.
class WebSocketConnection {
  /// Set token verified
  WebSocketConnection(
      {required this.id,
      required this.socket,
      this.token,
      required this.webSocketService}) {
    _listen();
  }

  void _listen() {
    incoming.listen((event) {
      webSocketService.onCall(event);
    });

    outgoing.listen((event) {
      socket.add(json.encode(event.toMap()));
    });

    socket.listen((event) async {
      _incomingController.sink.add(await webSocketService._messageTransformer
          .convertIncoming(event as Object, this));
    });
    //TODO:
  }

  ///
  void dispose() {
    socket.close();
    _incomingController.close();
  }

  ///
  WebSocket socket;

  ///
  AccessToken? token;

  ///
  WebSocketService webSocketService;

  ///
  BuildContext get context => webSocketService.context;

  ///
  bool get connected => socket.closeCode == null;

  ///
  String id;

  ///
  late final StreamController<WebSocketMessage> _incomingController =
      StreamController<WebSocketMessage>.broadcast();

  ///
  Stream<WebSocketMessage> get incoming => _incomingController.stream;

  ///
  late final StreamController<Message> _outgoingController =
      StreamController<Message>.broadcast();

  ///
  Stream<Message> get outgoing => _outgoingController.stream;

  ///
  Nonce? clientNonce, serverNonce;

  ///
  bool get nonceReceived => clientNonce != null && serverNonce != null;

  ///
  bool waitReceivedMessage = true;

  ///
  Duration waitTimeout = Duration(seconds: 30);

  ///
  Future<WebSocketMessage> send(WebSocketMessage message) {
    var completer = Completer<WebSocketMessage>();
    incoming.firstWhere((element) => element.id == message.id).then((value) {
      completer.complete(value);
    }).timeout(waitTimeout, onTimeout: () {
      //TODO: Specify exception
      throw Exception('Message Timeout');
    }).catchError((Object e, StackTrace s) {
      completer.completeError(e, s);
    });
    //TODO: _outgoingController.sink.add(message);
    return completer.future;
  }

// static FutureOr<WebSocketMessage?> Function(dynamic event) _convert(
//     WebSocketConnection connection) {
//   return (event) {
//     dynamic jsonMessage;
//     if (event is String) {
//       jsonMessage = json.decode(event);
//     } else {
//       jsonMessage = json.decode(utf8.decode(event));
//     }
//
//     if (jsonMessage is! Map<String, dynamic>) {
//       Logger.of(connection.context)
//           .warn(connection.context, "unexpected_ws_message",
//               payload: {
//                 "expected": "Map<String,dynamic>",
//                 "actual": jsonMessage.runtimeType.toString(),
//                 "connection": connection.id,
//                 "token": connection.token?.toMap()
//               },
//               title: "Unexpected WebSocket Message is dangerous. "
//                   "Messages that do not conform to the messaging protocol "
//                   "can be an indication of an attack.");
//       return null;
//     }
//
//     if (jsonMessage["t"] == "r") {
//       return WebSocketRequest(
//           path: jsonMessage["p"],
//           id: jsonMessage["i"],
//           connection: connection,
//           body: JsonBody(jsonMessage["d"]));
//     } else if (jsonMessage["t"] == "cr") {
//       return WebSocketClientResponse(
//           id: jsonMessage["i"],
//           eventName: jsonMessage["p"],
//           connection: connection,
//           body: JsonBody(jsonMessage["d"]));
//     }
//     return null;
//   };
// }

// static FutureOr<WebSocketMessage?> Function(dynamic event)
// _convertEncrypted(
//     WebSocketConnection connection) {
//   try {
//     return (event) async {
//       try {
//         dynamic jsonMessage;
//         if (event is String) {
//           jsonMessage = json.decode(event);
//         } else {
//           jsonMessage = json.decode(utf8.decode(event));
//         }
//
//         if (jsonMessage is! Map<String, dynamic>) {
//           Logger.of(connection.context).warn(
//               connection.context, "unexpected_ws_message",
//               payload: {
//                 "expected": "Map<String,dynamic>",
//                 "actual": jsonMessage.runtimeType.toString(),
//                 "connection": connection.id,
//                 "token": connection.token?.toMap()
//               },
//               title: "Unexpected WebSocket Message is dangerous. "
//                   "Messages that do not conform to the messaging protocol "
//                   "can be an indication of an attack.");
//           return null;
//         }
//
//         if (!connection.nonceReceived) {
//           if (jsonMessage["p"] == "n_e1" || jsonMessage["p"] == "n_e2") {
//             return WebSocketClientResponse(
//                 eventName: jsonMessage["p"],
//                 id: jsonMessage["i"],
//                 connection: connection,
//                 body: JsonBody(jsonMessage["d"]));
//           } else {
//             Logger.of(connection.context).warn(
//                 connection.context, "unexpected_ws_message",
//                 payload: {
//                   "expected": "\"n_e1\"||\"n_e2\"",
//                   "actual": jsonMessage["p"],
//                   "connection": connection.id,
//                   "token": connection.token?.toMap()
//                 },
//                 title: "Unexpected WebSocket Event is dangerous. "
//                     "Messages that do not
//                     conform to the messaging protocol "
//                     "can be an indication of an attack.");
//             return null;
//           }
//         }
//
//         if (jsonMessage["d"] is String &&
//         jsonMessage["d"].startsWith("en")) {
//           jsonMessage["d"] = await Crypto.of(connection.context).decrypt(
//               jsonMessage["d"].subString(2),
//               connection.clientNonce!.bytes,
//               connection.serverNonce!.bytes);
//         } else {
//           Logger.of(connection.context).warn(
//               connection.context, "unexpected_ws_message",
//               payload: {
//                 "expected": "encrypted",
//                 "actual": jsonMessage["d"],
//                 "connection": connection.id,
//                 "token": connection.token?.toMap()
//               },
//               title: "Unexpected WebSocket Event is dangerous. "
//                   "Messages that do not conform to the messaging protocol "
//                   "can be an indication of an attack.");
//
//           throw BadRequests();
//         }
//         return null;
//       } on Exception {
//         rethrow;
//       }
//     };
//   } on Exception {
//     rethrow;
//   }
// }

// ///
// void _listen() {
//   if (webSocketService.messageEncryption) {
//     socketStream =
//         socket.asyncMap<WebSocketMessage?>(_convertEncrypted(this));
//   } else {
//     socketStream = socket.asyncMap<WebSocketMessage?>(_convert(this));
//   }
// }

  ///
//TODO:

}

///
class DefaultWSMessageTransformer with WebSocketMessageTransformer {
  @override
  FutureOr<WebSocketMessage> convertIncoming(
      Object raw, WebSocketConnection connection) {
    try {
      var encoded = json.decode(raw as String) as Map<String, dynamic>;
      return WebSocketRequest(
          path: encoded['path'] as String,
          id: encoded['id'] as String,
          connection: connection,
          body: encoded['body'] != null
              ? JsonBody(encoded['body'] as Map<String, dynamic>)
              : null);
    } on Exception {
      rethrow;
    }
  }

  @override
  FutureOr<List<int>> convertOutgoing(WebSocketMessage message) {
    // TODO: implement convertOutgoing
    throw UnimplementedError();
  }
}

///
mixin WebSocketMessageTransformer {
  ///
  FutureOr<WebSocketMessage> convertIncoming(
      Object raw, WebSocketConnection connection);

  ///
  FutureOr<List<int>> convertOutgoing(WebSocketMessage message);
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
