
part of '../../style_base.dart';



/// Request [Cause].
/// Indicates why this request is made.
enum Cause {
  /// Client request that received [Agent.ws] or [Agent.http].
  clientRequest,

  /// Requests created by triggers before the request was responded.
  requestTrigger,

  /// Requests created by triggers after the request is responded.
  responseTrigger,

  /// Requests created by [CronJobs]
  cronJobs,

  /// Requests created by [Admin]
  /// Admin is style monitoring app user or internal server coders
  admin
}