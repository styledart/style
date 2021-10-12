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
    throw UnimplementedError();
  }

  ///
  void operator []=(covariant String key, dynamic value) {
    throw UnimplementedError();
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

  ///
  Pattern operator [](covariant int key) {
    return data[key];
  }

  ///
  void operator []=(covariant int key, covariant Pattern value) {
    // TODO: implement []=
  }
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
    // TODO: implement []
    throw UnimplementedError();
  }

  ///
  void operator []=(covariant int key, covariant int value) {
    // TODO: implement []=
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
  Request._(
      {required RequestContext context,
      ContentType? contentType,
      dynamic body,
      this.headers,
      this.cookies,
      this.method})
      : super(body: body, context: context, contentType: contentType);

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
  final HttpHeaders? headers;

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
  Response createResponse(dynamic body,
      {int statusCode = 200,
      Map<String, dynamic>? headers,
      DateTime? lastModified,
      String? etag}) {
    return Response(
        additionalHeaders: headers,
        body: body == null ? NullBody() : Body(body),
        request: this,
        statusCode: statusCode,
        etag: etag,
        lastModified: lastModified);
  }
}

class _RequestFactory extends Request {
  _RequestFactory(Request request)
      : super._(
            context: request.context,
            body: request.body,
            headers: request.headers,
            cookies: request.cookies,
            contentType: request.contentType,
            method: request.method);
}

///
class Response extends Message {
  /// Creates with subclasses
  Response(
      {required Request request,
      Body? body,
      required this.statusCode,
      this.additionalHeaders,
      this.etag,
      this.lastModified})
      : super(body: body, context: request.context);

  DateTime? lastModified;
  String? etag;

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
      : super._(
            context: context,
            body: body,
            contentType: contentType,
            cookies: baseRequest.cookies,
            headers: baseRequest.headers,
            method: method);

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

    return HttpStyleRequest(
        baseRequest: req,
        contentType: req.headers.contentType,
        method: Methods.values[_m.indexOf(req.method)],
        context: RequestContext(
            requestTime: DateTime.now(),
            currentContext: context,
            cause: Cause.clientRequest,
            agent: Agent.http,
            accessToken: req.uri.queryParameters["token"] ??
                req.headers[HttpHeaders.authorizationHeader]?.first,
            createContext: context,
            fullPath: req.uri.path),
        body: body);
  }
}

///
class TagRequest extends Request {
  ///
  TagRequest(Request request) : super.fromRequest(request);

  TagResponse response(String tag) {
    return TagResponse(this, tag: tag);
  }
}

///
class TagResponse extends Response {
  ///
  TagResponse(TagRequest request, {required this.tag, ContentType? contentType})
      : super(request: request, statusCode: 304);

  String tag;
}

///
class ModifiedSinceRequest extends Request {
  ///
  ModifiedSinceRequest(Request request) : super.fromRequest(request);

  ModifiedSinceResponse response(DateTime lastModified) {
    return ModifiedSinceResponse(this, lastMod: lastModified);
  }
}

///
class ModifiedSinceResponse extends Response {
  ///
  ModifiedSinceResponse(ModifiedSinceRequest request,
      {required this.lastMod, ContentType? contentType})
      : super(request: request, statusCode: 304);

  DateTime lastMod;
}

///
class NoResponseRequired extends Response {
  ///
  NoResponseRequired({
    required Request request,
  }) : super(statusCode: -1, request: request, additionalHeaders: {});
}
