part of '../../style_base.dart';

///
abstract class Message {
  ///
  Message(
      {required this.responded,
      required this.context,
      required this.body,
      required this.responseCreated}) ;

  ///
  bool responseCreated;

  ///
  bool responded;

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
  PathSegment get currentPath => path.current;

  /// Request Body
  /// Http requests body or web socket messages "body" values
  /// In Cron Jobs body is empty
  Map<String, dynamic> body;

  /// Request [Cause].
  /// Indicates why this request is made.
  Cause get cause => context.cause;

  /// [Request] agent.
  /// Example: The agent of all http/(s) requests received by the server is [Agent.http]
  Agent get agent => context.agent;

  // TODO: Call Path Builder
  // TODO: Call Path

  /// Data access state of current context
  ///
  /// At the point where the request is handled , not only endpoint
  DataAccess get dataAccess => context.currentContext.dataAccess;
}

// ///
// mixin AgentMixin {
//   /// Http
//   bool get isHttp => this == Http;
//
//   /// Web Socket
//   bool get isWs => this == Ws;
//
//   /// Internal
//   bool get isInternal => this == Internal;
// }
//
// ///
// mixin Http implements AgentMixin {}
//
// ///
// mixin Ws implements AgentMixin {}
//
// ///
// mixin Internal implements AgentMixin {}

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
      {required RequestContext context, required Map<String, dynamic> body})
      : super(
            responded: false,
            responseCreated: false,
            body: body,
            context: context);

  @override
  Response createResponse(Map<String, dynamic> body, {int? statusCode, Map<String, dynamic>? additionalHeader}) {
    return Response(request: this, body: body)..responseCreated = true;
  }
}

///
class Response extends Message {
  /// Creates with subclasses
  Response(
      {required Request request,
      required Map<String, dynamic> body})
      : super(
            responded: false,
            responseCreated: false,
            body: body,
            context: request.context);

  ///
  // factory Response(
  //     {required Request request, required Map<String, dynamic> body}) {
  //   if (T == Http) {
  //     return HttpResponse(
  //         context: request.context,
  //         body: body,
  //         fullPath: request.fullPath) as Response;
  //   } else if (T == Ws) {
  //     return WsResponse(
  //         context: request.context,
  //         body: body,
  //         fullPath: request.fullPath) as Response;
  //   } else {
  //     return InternalResponse(
  //         context: request.context,
  //         body: body,
  //         fullPath: request.fullPath) as Response<T>;
  //   }
  // }
}

///
class HttpRequest extends Request {
  ///
  HttpRequest(
      {required RequestContext context, required Map<String, dynamic> body})
      : super._(context: context, body: body);

  factory HttpRequest.fromRequest(
      {required io.HttpRequest req,
      required Map<String, dynamic> json,
      required BuildContext context}) {
    return HttpRequest(
        context: RequestContext(
            requestTime: DateTime.now(),
            currentContext: context,
            cause: Cause.clientRequest,
            agent: Agent.http,
            createContext: context,
            fullPath: req.uri.path),
        body: json);
  }
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

///
class WsRequest extends Request {
  ///
  WsRequest(
      {required RequestContext context, required Map<String, dynamic> body})
      : super._(context: context, body: body);


}

// ///
// class WsResponse extends Response{
//   ///
//   WsResponse(
//       {required RequestContext context,
//       required String fullPath,
//       required Map<String, dynamic> body})
//       : super._(context: context, fullPath: fullPath, body: body);
// }

///
class InternalRequest extends Request {
  ///
  InternalRequest(
      {required RequestContext context, required Map<String, dynamic> body})
      : super._(context: context, body: body);
}

// ///
// class InternalResponse extends Response {
//   ///
//   InternalResponse(
//       {required RequestContext context,
//       required String fullPath,
//       required Map<String, dynamic> body})
//       : super._(context: context, fullPath: fullPath, body: body);
// }
