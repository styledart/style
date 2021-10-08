part of '../style_base.dart';

///
abstract class StyleException implements Exception {
  ///
  int get statusCode;
}

///
class InternalServerError extends ServerError {
  @override
  int get statusCode => 500;
}


///
abstract class ClientError extends StyleException {

}

///
abstract class ServerError extends StyleException {

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
class ServiceUnavailable extends ServerError {
  ///
  ServiceUnavailable(this.message);

  ///
  String message;

  @override
  int get statusCode => 503;
}
