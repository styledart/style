part of '../../style_base.dart';

/// [Request] agent.
/// Example: The agent of all http/(s) requests received by the server is [Agent.http]
enum Agent {
  /// Http/(s) Request
  http,

  /// Web Socket Request
  ws,

  /// Internal Request
  /// Like user service calling another service
  internal
}
