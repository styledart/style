part of '../../style_base.dart';

/// Log everything
abstract class Logger extends _BaseService {
  ///
  void log(LogMessage logMessage);

  void _log(LogLevel level, BuildContext context, String name,
      {Map<String, dynamic>? payload, String? customId}) {
    return log(LogMessage(
        loggerContext: context,
        customId: customId,
        payload: payload,
        name: name,
        level: level));
  }

  ///
  void verbose(BuildContext context, String name,
      {Map<String, dynamic>? payload, String? customId}) {
    return _log(LogLevel.verbose, context, name,
        payload: payload, customId: customId);
  }

  ///
  void info(BuildContext context, String name,
      {Map<String, dynamic>? payload, String? customId}) {
    return _log(LogLevel.info, context, name,
        payload: payload, customId: customId);
  }

  ///
  void error(BuildContext context, String name,
      {Map<String, dynamic>? payload, String? customId}) {
    return _log(LogLevel.error, context, name,
        payload: payload, customId: customId);
  }

  ///
  void warn(BuildContext context, String name,
      {Map<String, dynamic>? payload, String? customId}) {
    return _log(LogLevel.warn, context, name,
        payload: payload, customId: customId);
  }

  ///
  void important(BuildContext context, String name,
      {Map<String, dynamic>? payload, String? customId}) {
    return _log(LogLevel.important, context, name,
        payload: payload, customId: customId);
  }
}

///
class DefaultLogger extends Logger {
  @override
  FutureOr<void> init() {}

  @override
  void log(LogMessage logMessage) {
    // TODO: implement log
  }
}

/// eg log
/// server_start
/// Server Started : Server started with 192.168.1.1
/// 14.00.21 16:18
/// {
///   agent: x,
///   cause: y,
///   token: a,
///   context: short_desc,
///   duration: 10 ms
/// }
///
class LogMessage {
  ///
  ///
  LogMessage(
      {String? customId,
      required this.loggerContext,
      required this.name,
      required this.level,
      this.payload})
      : id = customId ?? getRandomId(20),
        time = DateTime.now();

  ///
  BuildContext loggerContext;

  ///
  DateTime time;

  ///
  String id, name;

  ///
  LogLevel level;

  ///
  Map<String, dynamic>? payload;
}

///
enum LogLevel {
  ///
  verbose,

  ///
  info,

  ///
  warn,

  ///
  error,

  ///
  important
}
