part of '../style_base.dart';

///
ExceptionSet exceptionSet = ExceptionSet._();

///
class ExceptionSet {
  ExceptionSet._();

  /// Base Style Exception
  static Type get style => StyleException;

  /// Base ServerError
  /// https://developer.mozilla.org/en-US/docs/Web/HTTP/Status#server_error_responses
  static Type get server => ServerError;

  /// Base ServerError
  /// https://developer.mozilla.org/en-US/docs/Web/HTTP/Status#client_error_responses
  static Type get client => ClientError;

  /// Bad Request
  /// https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/400
  static Type get e400 => ClientError;

  /// Unauthorized
  /// https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/401
  static Type get e401 => UnauthorizedException;

  /// Payment Required
  /// https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/402
  static Type get e402 => PaymentRequired;

  /// Forbidden
  /// https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/403
  static Type get e403 => ForbiddenUnauthorizedException;

  /// Not Found
  /// https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/404
  static Type get e404 => NotFoundException;

// TODO : Add others #13

}

///
abstract class StyleException<T extends Exception> implements Exception {
  ///
  int get statusCode;

  ///
  Type get superType => T;
}

///
abstract class ClientError extends StyleException<ClientError> {}

///
abstract class ServerError extends StyleException<ServerError> {}

///
class BadRequests extends ClientError {
  @override
  int get statusCode => 400;
}

///
class UnauthorizedException extends ClientError {
  @override
  int get statusCode => 401;
}

///
class PaymentRequired extends ClientError {
  @override
  int get statusCode => 402;
}

///
class ForbiddenUnauthorizedException extends ClientError {
  @override
  int get statusCode => 403;
}

///
class NotFoundException extends ClientError {
  @override
  int get statusCode => 404;
}

///
class MethodNotAllowedException extends ClientError {
  @override
  int get statusCode => 405;
}

///
class NotAcceptableException extends ClientError {
  @override
  int get statusCode => 406;
}

///
class ProxyAuthenticationException extends ClientError {
  @override
  int get statusCode => 407;
}

///
class RequestTimeoutException extends ClientError {
  @override
  int get statusCode => 408;
}

///
class ConflictsException extends ClientError {
  @override
  int get statusCode => 409;
}

///
class GoneException extends ClientError {
  @override
  int get statusCode => 410;
}

///
class LengthRequiredException extends ClientError {
  @override
  int get statusCode => 411;
}

///
class PreconditionFailed extends ClientError {
  @override
  int get statusCode => 412;
}

///
class PayloadTooLarge extends ClientError {
  @override
  int get statusCode => 413;
}

///
class UriTooLong extends ClientError {
  @override
  int get statusCode => 414;
}

///
class UnsupportedMediaType extends ClientError {
  @override
  int get statusCode => 415;
}

///
class RangeNotSatisfiable extends ClientError {
  @override
  int get statusCode => 416;
}

///
class ExpectationFailed extends ClientError {
  @override
  int get statusCode => 417;
}

///
class IamATeapot extends ClientError {
  @override
  int get statusCode => 418;
}

///
class MisdirectedRequest extends ClientError {
  @override
  int get statusCode => 421;
}

///
class UnprocessableEntity extends ClientError {
  @override
  int get statusCode => 422;
}

///
class LockedException extends ClientError {
  @override
  int get statusCode => 423;
}

///
class FailedDependency extends ClientError {
  @override
  int get statusCode => 424;
}

///
class TooEarlyException extends ClientError {
  @override
  int get statusCode => 425;
}

///
class UpgradeRequired extends ClientError {
  @override
  int get statusCode => 426;
}

///
class PreconditionRequired extends ClientError {
  @override
  int get statusCode => 428;
}

///
class TooManyRequests extends ClientError {
  @override
  int get statusCode => 429;
}

///
class RequestHeaderFieldsTooLarge extends ClientError {
  @override
  int get statusCode => 431;
}

///
class UnavailableForLegalReasons extends ClientError {
  @override
  int get statusCode => 451;
}

///
class InternalServerError extends ServerError {
  @override
  int get statusCode => 500;
}

///
class NotImplemented extends ServerError {
  @override
  int get statusCode => 501;
}

///
class BadGateway extends ServerError {
  @override
  int get statusCode => 502;
}

///
class ServiceUnavailable extends ServerError {
  ///
  ServiceUnavailable(this.message);

  ///
  String message;

  @override
  int get statusCode => 503;
}

///
class TimeoutException extends ServerError {
  @override
  int get statusCode => 504;
}

///
class HttpVersionNotSupported extends ServerError {
  @override
  int get statusCode => 505;
}

///
class VariantAlsoNegotiates extends ServerError {
  @override
  int get statusCode => 506;
}

///
class InsufficientStorage extends ServerError {
  @override
  int get statusCode => 507;
}

///
class LoopDetected extends ServerError {
  @override
  int get statusCode => 508;
}

///
class NotExtendedException extends ServerError {
  @override
  int get statusCode => 510;
}

///
class NetworkAuthenticationRequired extends ServerError {
  @override
  int get statusCode => 511;
}
