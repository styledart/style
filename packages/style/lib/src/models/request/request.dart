part of '../../style_base.dart';


class NullBody  extends Body<Null> {
  NullBody() : super._(null);
}

///
class Body<T> {
  ///
  Body._(this.data);

  /// Body create available body types
  ///
  /// Json format : JsonBody,
  /// Uint8List : BinaryBody,
  /// Text : HtmlBody
  ///
  /// To ensure text use TextBody
  ///
  factory Body(T data) {
    if (data is Body<T>) {
      return data;
    }
    if (data is Map<String, dynamic> || data is List) {
      return JsonBody(data) as Body<T>;
    } else if (data is String) {
      if (data.startsWith("<")) {
        return HtmlBody(data) as Body<T>;
      }
      return TextBody(data) as Body<T>;
    } else if (data is List<int>) {
      return BinaryBody(data as Uint8List) as Body<T>;
    }

    return Body._(data);
  }

  ///
  T data;

  ///
  @override
  String toString() {
    return data.toString();
  }
}

///
class JsonBody extends Body<dynamic> {
  ///
  JsonBody(dynamic data)
      : assert(data is List || data is Map<String, dynamic>),
        super._(data);

  ///
  dynamic operator [](covariant String key) {
    return data[key];
  }

  ///
  void operator []=(covariant String key, dynamic value) {
    data[key] = value;
  }

  ///
  @override
  String toString() {
    return json.encode(data);
  }
}

///
class TextBody extends Body<String> {
  ///
  TextBody(String data) : super._(data);
}

///
class HtmlBody extends TextBody {
  ///
  HtmlBody(String data) : super(data);
}

///
class BinaryBody extends Body<Uint8List> {
  ///
  BinaryBody(Uint8List data) : super._(data);

  ///
  int operator [](covariant int key) {
    return data[key];
  }

  ///
  void operator []=(covariant int key, covariant int value) {
    data[key] = value;
  }
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
  PathController get path => context.pathController;

  ///
  String get currentPath => path.current;

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

  ContentType? contentType;

  // TODO: Call Path Builder
  // TODO: Call Path

  /// Data access state of current context
  ///
  /// At the point where the request is handled , not only endpoint
  DataAccess get dataAccess => context.currentContext.dataAccess;
}

///
enum Methods {
  //ignore_for_file: constant_identifier_names , public_member_api_docs
  GET,
  POST,
  DELETE,
  PUT,
  PATCH,
  OPTIONS,
  HEAD,
  CONNECT,
  TRACE
}

var _m = [
  "GET",
  "POST",
  "DELETE",
  "PUT",
  "PATCH",
  "OPTIONS",
  "HEAD",
  "CONNECT",
  "TRACE"
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
      dynamic body,
      this.headers,
      this.cookies,
      this.method})
      : super(body: body, context: context, contentType: contentType);

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

  Map<String, dynamic> get arguments => path.arguments;

  Methods? method;

  ///
  Future<bool> ensureResponded() async {
    if (_waiter != null) return await _waiter!.future;
    _waiter = Completer<bool>();
    return _waiter!.future;
  }

  ///
  Response response(dynamic body,
      {int? statusCode, Map<String, dynamic>? headers}) {
    return Response(
        body: body is Body ? body : Body(body),
        request: this,
        statusCode: statusCode ?? 200,
        additionalHeaders: headers);
  }
}

///
class Response extends Message {
  /// Creates with subclasses
  Response(
      {required Request request,
      Body? body,
      required this.statusCode,
      this.additionalHeaders})
      : super(body: body, context: request.context);

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
    } else if (body is TextBody) {
      return ContentType.text;
    } else {
      return null;
    }
  }

  ///
  ContentType? get contentType {
    return _contentType(body);
  }

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

  ///
  final HttpRequest baseRequest;

  ///
  factory HttpStyleRequest.fromRequest(
      {required HttpRequest req,
      required dynamic body,
      required BuildContext context}) {
    // print("AUTH:::: "
    //     "${req.uri.queryParameters["token"]
    //     ?? req.headers[HttpHeaders.authorizationHeader]}");

    var q = req.uri.queryParameters;
    return HttpStyleRequest(
        baseRequest: req,
        contentType: req.headers.contentType,
        method: Methods.values[_m.indexOf(req.method)],
        context: RequestContext(
            requestTime: DateTime.now(),
            currentContext: context,
            cause: Cause.clientRequest,
            agent: Agent.http,
            accessToken: req.headers[HttpHeaders.authorizationHeader]?.first ??
                q["token"],
            // TODO: Look cookies for token
            createContext: context,
            pathController: PathController.fromHttpRequest(req)),
        body: body);
  }
}

///
class TagRequest extends Request {
  ///
  TagRequest(HttpStyleRequest request)
      : super(
            context: request.context,
            body: request.body,
            headers: request.headers,
            cookies: request.cookies);
}

///
class TagResponse extends Response {
  ///
  TagResponse(TagRequest request,
      {required String tag, ContentType? contentType})
      : super(request: request, statusCode: 304, additionalHeaders: {
          HttpHeaders.contentLengthHeader: 0,
          HttpHeaders.etagHeader: tag
        });
}

///
class NoResponseRequired extends Response {
  ///
  NoResponseRequired({
    required Request request,
  }) : super(statusCode: -1, request: request, additionalHeaders: {});
}

// ///
// class HttpResponse extends Response {
//   ///
//   HttpResponse(
//       {required RequestContext context,
//       required String fullPath,
//       required Map<String, dynamic> body})
//       : super(context: context, fullPath: fullPath, body: body);
// }
//
// ///
// class WsRequest extends Request {
//   ///
//   WsRequest(
//       {required RequestContext context, required Map<String, dynamic> body})
//       : super._(context: context, body: body, accepts: [ContentType.json]);
// }
//
// // ///
// // class WsResponse extends Response{
// //   ///
// //   WsResponse(
// //       {required RequestContext context,
// //       required String fullPath,
// //       required Map<String, dynamic> body})
// //       : super._(context: context, fullPath: fullPath, body: body);
// // }
//
// ///
// class InternalRequest extends Request {
//   ///
//   InternalRequest({required RequestContext context, required dynamic body})
//       : super._(context: context, body: body, accepts: [
//           ContentType.json,
//           ContentType.text,
//           ContentType.html,
//           ContentType.binary
//         ]);
// }

// ///
// class InternalResponse extends Response {
//   ///
//   InternalResponse(
//       {required RequestContext context,
//       required String fullPath,
//       required Map<String, dynamic> body})
//       : super._(context: context, fullPath: fullPath, body: body);
// }
