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
//ignore: prefer_void_to_null
class NullBody extends Body<Null> {
  ///
  NullBody() : super._(null);

  @override
  List<int> toBytes() => [0];
}

class StreamBody<T> extends Body<Stream<Body<T>>> {
  StreamBody(Stream<Body<T>> stream, {this.deferredContentType})
      : super._(stream);

  ContentType? deferredContentType;

  Stream<Body<T>> get stream => super.data;

  Stream<List<int>> get streamBytes => stream.transform(
          StreamTransformer<Body<T>, List<int>>.fromBind((p0) async* {
        await for (var b in p0) {
          yield b.toBytes();
        }
      }));

  @override
  List<int> toBytes() => throw UnimplementedError();
}

///
abstract class Body<T> {
  ///
  Body._(this.data);

  /// Body create available body types
  ///
  factory Body(T data) {
    if (data is Body<T>) {
      return data;
    }
    if (data is List<int>) {
      return BinaryBody(data as Uint8List) as Body<T>;
    }
    if (data is Map<String, dynamic> || data is List) {
      return JsonBody(data as Object) as Body<T>;
    } else if (data is String) {
      if (isHtml(data)) {
        return HtmlBody(data) as Body<T>;
      }
      return StringBody(data) as Body<T>;
    } else if (data == null) {
      return NullBody() as Body<T>;
    }

    return NullBody() as Body<T>;
  }

  ///
  T data;

  /// Text content is html
  @visibleForTesting
  static bool isHtml(String value) {
    var i = 0;
    while (true) {
      if (i >= value.length) return false;
      if (value[i] == '<') {
        return true;
      } else if (value[i] != '\n' && value[i] != ' ') {
        return false;
      }
      i++;
    }
  }

  ///
  @override
  String toString() => data.toString();

  List<int> toBytes();
}

///
class JsonBody extends Body<dynamic> {
  ///
  JsonBody(Object data)
      : assert(data is List || data is Map<String, dynamic>),
        super._(data);

  ///
  dynamic operator [](covariant String key) =>
      (data as Map<String, dynamic>)[key];

  ///
  void operator []=(covariant String key, dynamic value) {
    (data as Map<String, dynamic>)[key] = value;
  }

  ///
  @override
  String toString() => json.encode(data);

  @override
  List<int> toBytes() => utf8.encode(toString());
}

///
class StringBody extends Body<String> {
  ///
  StringBody(String data) : super._(data);

  @override
  List<int> toBytes() => utf8.encode(data);
}

///
class HtmlBody extends StringBody {
  ///
  HtmlBody(String data) : super(data);
}

///
class BinaryBody extends Body<Uint8List> {
  ///
  BinaryBody(Uint8List data) : super._(data);

  ///
  int operator [](covariant int key) => data[key];

  ///
  void operator []=(covariant int key, covariant int value) {
    data[key] = value;
  }

  @override
  List<int> toBytes() => data;
}

///
abstract class Message {
  ///
  Message({ContentType? contentType, required this.context, required this.body})
      : contentType = contentType ?? Response._contentType(body);

  /// [RequestContext] is context of request info about handling, creating,
  /// responding
  final RequestContext context;

  /// Request Full Path
  /// include host and scheme and query parameters
  /// examples :
  /// http request : [https://localhost:9090/a/b?c=d]
  /// web socket req. : [ws://a/b?c=d]
  /// internal req. : [style://a/b?c=d]
  String get fullPath => path.calledPath;

  ///
  AccessToken? get auth => context.accessToken;

  ///
  PathController get path => context.pathController;

  ///
  String get nextPathSegment => path.next;

  /// Request Body
  /// Http requests body or web socket messages "body" values
  /// In Cron Jobs body is empty
  Body? body;

  /// Request [Cause].
  /// Indicates why this request is made.
  Cause get cause => context.cause;

  /// [Request] agent.
  /// Example: The agent of all http/(s) requests received by the server is [Agent.http]
  Agent get agent => context.agent;

  /// Http GET method
  ContentType? contentType;

  ///
  Map<String, dynamic> toMap() => {
        if (auth != null) 'token': auth!.toMap(),
        'path': path.toMap(),
        'agent': agent.index,
        'cause': cause.index,
        'create': context.requestTime.millisecondsSinceEpoch
      };

// TODO: Call Path Builder
// TODO: Call Path

}

///
enum Methods {
  //ignore_for_file: constant_identifier_names
  /// Http GET method
  GET,

  /// Http POST method
  POST,

  /// Http DELETE method
  DELETE,

  /// Http PUT method
  PUT,

  /// Http PATCH method
  PATCH,

  /// Http OPTIONS method
  OPTIONS,

  /// Http HEAD method
  HEAD,

  /// Http CONNECT method
  CONNECT,

  /// Http TRACE method
  TRACE
}

var _m = [
  'GET',
  'POST',
  'DELETE',
  'PUT',
  'PATCH',
  'OPTIONS',
  'HEAD',
  'CONNECT',
  'TRACE'
];

/// All requests from client or in-server
/// triggered with [Request]
///
/// All Requests generate a [Request] regardless of the agent.
/// It should not be perceived as requests only from the client.
/// All triggers, cron jobs and internal requests are [Request].
/// So all request have create [Cause].
///
/// These created requests are made by any ways. So, the [Agent] of all these
/// requests is also necessary.
/// There are all possible agent and cause in enum are [Agent] and [Cause].
///
/// [Agent] and  [Cause] stored [RequestContext]
///
/// And defined [agent] and [cause] getters in [Request]
///
abstract class Request extends Message {
  /// Creates with subclasses
  Request(
      {required RequestContext context,
      ContentType? contentType,
      Body? body,
      this.headers,
      this.cookies,
      this.method})
      : super(body: body, context: context, contentType: contentType);

  ///
  Request.fromRequest(Request request)
      : headers = request.headers,
        cookies = request.cookies,
        method = request.method,
        super(
            context: request.context,
            body: request.body,
            contentType: request.contentType);

  ///
  final List<Cookie>? cookies;

  ///
  final Map<String, List<String>>? headers;

  ///
  Completer<bool>? _waiter;

  bool? _responded;

  /// if sending operation not resulted
  /// sent is null
  /// if success, sent is true
  /// if operation failed, sent is false
  bool? get responded => _responded;

  set responded(bool? value) {
    _responded = value!;
    if (_waiter != null) {
      _waiter!.complete(value);
    }
  }

  ///
  Map<String, dynamic> get arguments => path.arguments;

  ///
  Methods? method;

  ///
  AccessToken? get token => context.accessToken;

  ///
  set token(AccessToken? token) {
    if (token == null) return;
    context.accessToken = token;
  }

  ///
  FutureOr<void> verifyTokenWith(Authorization authorization) async {
    try {
      if (context.tokenVerified) {
        return;
      }
      if (token == null) {
        throw UnauthorizedException();
      }
      await authorization.verifyToken(token!);
      context.tokenVerified = true;
    } on Exception {
      rethrow;
    }
  }

  ///
  Future<bool> ensureResponded() async {
    if (_waiter != null) return await _waiter!.future;
    _waiter = Completer<bool>();
    return _waiter!.future;
  }

  ///
  Response response(Body? body,
          {int? statusCode,
          Map<String, dynamic>? headers,
          ContentType? contentType}) =>
      Response(
          body: Body(body),
          request: this,
          statusCode: statusCode ?? 200,
          additionalHeaders: headers,
          contentType: contentType);

  ///
  factory Request.fromMap(
          Map<String, dynamic> map, HttpRequest base, RequestContext context) =>
      HttpStyleRequest(
          baseRequest: base,
          body: map['body'] as Body?,
          method: Methods.values[map['method'] as int],
          context: context,
          contentType: ContentType.parse(map['content_type'] as String));
}

///
class Response extends Message {
  /// Creates with subclasses
  Response(
      {required Request request,
      Body? body,
      required this.statusCode,
      this.additionalHeaders,
      ContentType? contentType})
      : super(body: body, context: request.context, contentType: contentType);

  ///
  int statusCode;

  ///
  Map<String, dynamic>? additionalHeaders;

  static ContentType? _contentType(Body? body) {
    if (body is JsonBody) {
      return ContentType.json;
    } else if (body is HtmlBody) {
      return ContentType.html;
    } else if (body is BinaryBody) {
      return ContentType.binary;
    } else if (body is StringBody) {
      return ContentType.text;
    } else {
      return null;
    }
  }

  ///
  //ContentType? get contentType;

  ///
  Completer<bool>? _waiter;

  bool? _sent;

  /// if sending operation not resulted
  /// sent is null
  /// if success, sent is true
  /// if operation failed, sent is false
  bool? get sent => _sent;

  set sent(bool? value) {
    _sent = value!;
    if (_waiter != null) {
      _waiter!.complete(value);
    }
  }

  ///
  Future<bool> ensureSent() async {
    if (_waiter != null) return await _waiter!.future;
    _waiter = Completer<bool>();
    return _waiter!.future;
  }
}

///
class HttpStyleRequest extends Request {
  ///
  HttpStyleRequest(
      {required this.baseRequest,
      required Methods method,
      required RequestContext context,
      ContentType? contentType,
      Body? body})
      : super(
            context: context,
            body: body,
            contentType: contentType,
            cookies: baseRequest.cookies,
            headers: _getHeaders(baseRequest.headers),
            method: method);

  static Map<String, List<String>> _getHeaders(HttpHeaders headers) {
    var m = <String, List<String>>{};
    headers.forEach((name, values) {
      m[name] = values;
    });

    return m;
  }

  @override
  Methods get method => super.method!;

  ///
  final HttpRequest baseRequest;

  ///
  static Future<HttpStyleRequest> fromRequest(
      {required HttpRequest req,
      required dynamic body,
      required BuildContext context}) async {
    var q = req.uri.queryParameters;
    var t = req.headers[HttpHeaders.authorizationHeader]?.first ?? q['token'];
    AccessToken? token;
    if (t != null && context.hasService<Authorization>()) {
      token = await Authorization.of(context).decryptToken(t);
    }
    return HttpStyleRequest(
        baseRequest: req,
        contentType: req.headers.contentType,
        method: Methods.values[_m.indexOf(req.method)],
        context: RequestContext(
            requestTime: DateTime.now(),
            cause: Cause.clientRequest,
            agent: Agent.http,
            accessToken: token,
            // TODO: Look cookies for token
            // createContext: context,
            pathController: PathController.fromHttpRequest(req)),
        body: body as Body?);
  }
}

///
class CronJobRequest extends Request {
  ///
  CronJobRequest(
      {required DateTime time, required String path, AccessToken? token})
      : super(
          context: RequestContext(
            requestTime: DateTime.now(),
            cause: Cause.cronJobs,
            agent: Agent.internal,
            accessToken: token,
            pathController: PathController.fromFullPath(path),
          ),
          body: Body<DateTime>(time),
        );
}

///
class NoResponseRequired extends Response {
  ///
  NoResponseRequired({
    required Request request,
  }) : super(statusCode: -1, request: request, additionalHeaders: {});
}

///
mixin WebSocketMessage {
  ///
  WebSocketConnection get connection;

  ///
  String get id;

  ///
  String? get eventIdentifier;
}

///
class WebSocketRequest extends Request with WebSocketMessage {
  ///
  WebSocketRequest(
      {Map<String, List<String>>? headers,
      required String path,
      required String id,
      String? eventIdentifier,
      required WebSocketConnection connection,
      Body? body,
      List<Cookie>? cookies,
      Methods? method})
      : _id = id,
        _connection = connection,
        _eventIdentifier = eventIdentifier,
        super(
          cookies: cookies,
          body: body,
          method: method,
          contentType: ContentType.json,
          headers: headers,
          context: RequestContext(
              requestTime: DateTime.now(),
              cause: Cause.clientRequest,
              agent: Agent.ws,
              pathController: PathController.fromFullPath(path)),
        );

  ///
  @override
  Response response(Body? body,
          {int? statusCode,
          Map<String, dynamic>? headers,
          ContentType? contentType,
          String? customResponseId,
          String? customEventIdentifier}) =>
      WebSocketResponse(
        body: body,
        request: this,
        connection: connection,
        statusCode: statusCode ?? 200,
        headers: headers,
        id: customResponseId ?? id,
        eventIdentifier: customEventIdentifier ?? eventIdentifier,
      );

  final WebSocketConnection _connection;

  final String _id;

  final String? _eventIdentifier;

  @override
  WebSocketConnection get connection => _connection;

  @override
  String get id => _id;

  @override
  String? get eventIdentifier => _eventIdentifier;
}

///
class WebSocketResponse extends Response with WebSocketMessage {
  ///
  WebSocketResponse(
      {Map<String, dynamic>? headers,
      required String id,
      String? eventIdentifier,
      required WebSocketConnection connection,
      required Body? body,
      required int statusCode,
      required WebSocketRequest request})
      : _id = id,
        _connection = connection,
        _eventIdentifier = eventIdentifier,
        super(
          statusCode: statusCode,
          request: request,
          additionalHeaders: headers,
          body: body,
          contentType: ContentType.json,
        );

  final WebSocketConnection _connection;

  final String _id;

  final String? _eventIdentifier;

  final responseCreated = DateTime.now();

  ///
  @override
  WebSocketConnection get connection => _connection;

  @override
  String get id => _id;

  @override
  String? get eventIdentifier => _eventIdentifier;

  ///
  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'path': path.calledPath,
        if (body != null) 'body': body!.data,
        'cause': cause.index,
        'create_time': context.requestTime.millisecondsSinceEpoch,
        'response_time': responseCreated.millisecondsSinceEpoch,
      };
}

///
class WebSocketServerRequest with WebSocketMessage {
  ///
  WebSocketServerRequest(
      {String? customID,
      required String eventName,
      required WebSocketConnection connection,
      required Body? body})
      : _id = customID ??
            connection.webSocketService.messageIdGenerator.generateString(),
        _connection = connection,
        _eventIdentifier = eventName,
        _body = body;

  ///
  Future<WebSocketClientResponse> sendAndWaitResponse() async {
    throw TimeoutException();
  }

  final WebSocketConnection _connection;

  final String _id;

  final String? _eventIdentifier;

  final Body? _body;

  Body? get body => _body;

  @override
  WebSocketConnection get connection => _connection;

  @override
  String get id => _id;

  @override
  String? get eventIdentifier => _eventIdentifier;
}

///
class WebSocketClientResponse with WebSocketMessage {
  ///
  WebSocketClientResponse({
    required String id,
    required String eventName,
    required WebSocketConnection connection,
    required Body? body,
  })  : _id = id,
        _connection = connection,
        _eventIdentifier = eventName,
        _body = body;

  final WebSocketConnection _connection;

  final String _id;

  final String? _eventIdentifier;

  final Body? _body;

  Body? get body => _body;

  ///
  @override
  WebSocketConnection get connection => _connection;

  @override
  String get id => _id;

  @override
  String? get eventIdentifier => _eventIdentifier;
}
