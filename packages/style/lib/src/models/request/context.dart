part of '../../style_base.dart';

/// It refers to the context in which the request
/// occurs and the [BuildContext] of the endpoints and gates it reaches.
class RequestContext {
  /// Not use
  RequestContext(
      {required this.requestTime,
      required this.cause,
      required this.agent,
      required this.createContext,
      required  this.pathController,
      this.accessToken}) : currentContext = createContext;

  /// Path-Call Controller
  PathController pathController;

  /// [BuildContext] is handled
  /// binding of component
  BuildContext currentContext;

  /// [BuildContext] is created
  /// binding of component
  BuildContext createContext;

  /// Request Create Time
  DateTime requestTime;

  /// Request [Cause].
  /// Indicates why this request is made.
  Cause cause;

  /// [Request] agent.
  /// Example: The agent of all http/(s) requests received by the server is [Agent.http]
  Agent agent;

  /// Access Token
  ///
  ///
  ///
  String? accessToken;
}
