part of '../style_base.dart';

///
abstract class StyleException implements Exception {
  ///
  int get statusCode;
}

///
class InternalServerError extends StyleException {
  @override
  int get statusCode => 500;
}

///
class TimeoutException extends StyleException {
  @override
  int get statusCode => 504;
}

///
class HttpVersionNotSupported extends StyleException {
  @override
  int get statusCode => 505;
}

///
class BadRequests extends StyleException {
  @override
  int get statusCode => 400;
}

///
class UnauthorizedException extends StyleException {
  @override
  int get statusCode => 401;
}

///
class PaymentRequired extends StyleException {
  @override
  int get statusCode => 402;
}

///
class ForbiddenUnauthorizedException extends StyleException {
  @override
  int get statusCode => 403;
}

///
class NotFoundException extends StyleException {
  @override
  int get statusCode => 404;
}

///
class MethodNotAllowedException extends StyleException {
  @override
  int get statusCode => 405;
}

///
class NotAcceptableException extends StyleException {
  @override
  int get statusCode => 406;
}

///
class ProxyAuthenticationException extends StyleException {
  @override
  int get statusCode => 407;
}

///
class RequestTimeoutException extends StyleException {
  @override
  int get statusCode => 408;
}

///
class ConflictsException extends StyleException {
  @override
  int get statusCode => 409;
}

///
class GoneException extends StyleException {
  @override
  int get statusCode => 410;
}

///
class LengthRequiredException extends StyleException {
  @override
  int get statusCode => 411;
}

///
class ServiceUnavailable extends StyleException {
  ///
  ServiceUnavailable(this.message);

  ///
  String message;

  @override
  int get statusCode => 503;
}
