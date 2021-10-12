part of '../../style_base.dart';

///
abstract class CacheControlDirective {
  ///
  const CacheControlDirective();

  /// e.g. max-age=100
  String get name;
}

///
class Cacheability extends CacheControlDirective {
  ///
  const Cacheability(this._name);

  ///
  Cacheability.public() : _name = "public";

  ///
  Cacheability.private() : _name = "private";

  ///
  Cacheability.noCache() : _name = "no-cache";

  ///
  Cacheability.noStore() : _name = "no-store";

  ///
  final String _name;

  @override
  String get name => _name;
}

///
class Expiration extends CacheControlDirective {
  ///
  const Expiration(this._name, this.duration);

  ///
  const Expiration.maxAge(this.duration) : _name = "max-age";

  ///
  const Expiration.sMaxAge(this.duration) : _name = "s-max-age";

  ///
  const Expiration.maxStale(this.duration) : _name = "max-stale";

  ///
  const Expiration.minFresh(this.duration) : _name = "min-fresh";

  ///
  const Expiration.staleWhileRevalidation(this.duration)
      : _name = "stale-while-revalidation";

  ///
  const Expiration.staleIfError(this.duration)
      : _name = "stale-if-error";

  ///
  final Duration duration;

  ///
  final String _name;

  ///
  @override
  String get name => "$_name=${duration.inSeconds}";
}

///
class Revalidation extends CacheControlDirective {
  ///
  const Revalidation(this._name, this.method);

  ///
  const Revalidation.mustRevalidate(this.method)
      : _name = "must-revalidate";

  ///
  const Revalidation.proxyRevalidate(this.method)
      : _name = "proxy-revalidate";

  ///
  const Revalidation.immutable()
      : method = null,
        _name = "immutable";

  ///
  final String _name;

  ///
  final RevalidationMethod? method;

  @override
  String get name => _name;
}

///
class ValidationResult {
  ///
  const ValidationResult.ok({required this.headers, required this.statusCode})
      : validate = true,
        assert((statusCode != null && headers != null));

  ///
  const ValidationResult.not()
      : validate = false,
        statusCode = null,
        headers = null;

  ///
  final bool validate;

  ///
  final int? statusCode;

  ///
  final Map<String, dynamic>? headers;
}

///
abstract class RevalidationMethod<T> {
  ///
  late BuildContext context;

  ///
  FutureOr<ValidationResult> validate(
      ValidationRequest<T> request, ValidationResponse<T> validationResponse);

  FutureOr<Message> _validateAndReturn(Request request,
      FutureOr<Message> Function(Request request) childCalling) async {
    var f = ValidationRequest.create(request);
    if (f == null || f is! ValidationRequest<T>) {
      return childCalling(request);
    }
    var res = await childCalling(f);
    if (res is ValidationResponse<T>) {
      var val = await validate(f, res);
      if (val.validate) {
        return request.createResponse(null,
            statusCode: val.statusCode!, headers: val.headers);
      } else {
        var c = await childCalling(request);
        return (c);
      }
    } else {
      context.logger
          .warn(context, "Validation Request requested but not handled");
      return childCalling(request);
    }
  }
}

///
class IfModifiedSinceMethod extends RevalidationMethod<DateTime> {
  @override
  FutureOr<ValidationResult> validate(ValidationRequest<DateTime> request,
      covariant ValidationResponse<DateTime> validationResponse) {
    if (validationResponse.value.millisecondsSinceEpoch ~/ 1000 >
        request.headers!.ifModifiedSince!.millisecondsSinceEpoch ~/ 1000) {
      return ValidationResult.not();
    } else {
      return ValidationResult.ok(headers: {
        HttpHeaders.lastModifiedHeader:
            HttpDate.format(validationResponse.value),
        HttpHeaders.contentLengthHeader: 0
      }, statusCode: 304);
    }
  }
}

///
class IfNoneMatchMethod extends RevalidationMethod<String> {
  @override
  FutureOr<ValidationResult> validate(ValidationRequest<String> request,
      covariant ValidationResponse<String> validationResponse) {
    if (request.validationData == validationResponse.value) {
      return ValidationResult.ok(headers: {
        HttpHeaders.etagHeader: validationResponse.value,
        HttpHeaders.contentLengthHeader: 0
      }, statusCode: 304);
    } else {
      return ValidationResult.not();
    }
  }
}

///
class ValidationRequest<T> extends Request {
  ///
  ValidationRequest.fromRequest(Request request, this.validationData)
      : super.fromRequest(request);

  ///
  T validationData;

  ///
  static ValidationRequest? create(Request request) {
    if (request.headers?.ifModifiedSince != null) {
      return ValidationRequest<DateTime>.fromRequest(
          request, request.headers!.ifModifiedSince!);
    } else if (request.headers?[HttpHeaders.ifMatchHeader] != null) {
      return ValidationRequest<String>.fromRequest(
          request, request.headers![HttpHeaders.ifMatchHeader]!.first);
    } else if (request.headers?[HttpHeaders.ifNoneMatchHeader] != null) {
      return ValidationRequest<String>.fromRequest(
          request, request.headers![HttpHeaders.ifNoneMatchHeader]!.first);
    } else if (request.headers?[HttpHeaders.ifRangeHeader] != null) {
      return ValidationRequest<String>.fromRequest(
          request, request.headers![HttpHeaders.ifRangeHeader]!.first);
    } else if (request.headers?[HttpHeaders.ifUnmodifiedSinceHeader] != null) {
      return ValidationRequest<DateTime>.fromRequest(
          request,
          HttpDate.parse(
              request.headers![HttpHeaders.ifUnmodifiedSinceHeader]!.first));
    }
  }

  ///
  ValidationResponse<T> validate(T value) =>
      ValidationResponse.fromRequest(this, value);
}

///
class ValidationResponse<T> extends Request {
  ///
  ValidationResponse.fromRequest(ValidationRequest<T> request, this.value)
      : super.fromRequest(request);

  ///
  T value;
}

// ///
// class EtagRequest extends ValidationRequest<String> {
//   ///
//   EtagRequest(Request request, String etag) : super.fromRequest(request, etag);
//   ///
//   EtagRequest validate(String value) =>
//       EtagResponse(this, value) as ValidationRequest<String>;
// }
//
// ///
// class EtagResponse extends ValidationResponse<String> {
//   ///
//   EtagResponse(EtagRequest request, String value)
//       : super.fromRequest(request, value);
// }
//
// ///
// class LastModifiedRequest extends ValidationRequest<DateTime> {
//   ///
//   LastModifiedRequest(Request request, DateTime validationData)
//       : super.fromRequest(request, validationData);
// }
//
// ///
// class LastModifiedResponse extends ValidationResponse<DateTime> {
//   ///
//   LastModifiedResponse(ValidationRequest<DateTime> request, DateTime value)
//       : super.fromRequest(request, value);
// }

///
class CacheControlBuilder {
  ///
  CacheControlBuilder({this.revalidation, this.cacheability, this.expiration});

  ///
  Cacheability? cacheability;

  ///
  Revalidation? revalidation;

  ///
  Expiration? expiration;

  ///
  Map<String, List<String>> get headers {
    return {
      HttpHeaders.cacheControlHeader: [
        if (cacheability != null) cacheability!.name,
        if (expiration != null) expiration!.name,
        if (revalidation != null) revalidation!.name
      ],
    };
  }
}

///
class CacheControl extends GateWithChild {
  ///
  CacheControl(
      {Cacheability? cacheability,
      Revalidation? revalidation,
      Expiration? expiration,
      required Component child})
      : cacheControl = CacheControlBuilder(
            expiration: expiration,
            cacheability: cacheability,
            revalidation: revalidation),
        super(child: child);

  ///
  final CacheControlBuilder cacheControl;

  @override
  SingleChildCallingBinding createBinding() => _CacheControlBinding(this);

  @override
  FutureOr<Message> onRequest(Request request,
      FutureOr<Message> Function(Request p1) childCalling) async {
    if (cacheControl.revalidation != null) {
      var r = await cacheControl.revalidation!.method!
          ._validateAndReturn(request, childCalling);
      if (r is Response) {
        r.additionalHeaders ??= {};
        r.additionalHeaders!.addAll(cacheControl.headers);
      }
      return r;
    } else {
      var r = await childCalling(request);
      if (r is Response) {
        r.additionalHeaders ??= {};
        r.additionalHeaders!.addAll(cacheControl.headers);
      }
      return r;
    }
  }
}

///
class _CacheControlBinding extends SingleChildCallingBinding {
  _CacheControlBinding(CacheControl component) : super(component);

  @override
  void attachToParent(Binding parent) {
    print("CACHE CONTROL ATTACH : $_logger");
    (component as CacheControl).cacheControl.revalidation?.method?.context =
        this;
    super.attachToParent(parent);
  }
}

class _EndpointState extends Endpoint {
  _EndpointState(this.call);

  final FutureOr<Message> Function(Request request) call;

  @override
  FutureOr<Message> onCall(Request request) {
    return call(request);
  }
}

class _LastModifiedState extends Endpoint with LastModifiedMixin {
  _LastModifiedState(this.call, this._lastModified);

  final FutureOr<Message> Function(Request request) call;
  final FutureOr<ValidationResponse<DateTime>> Function(
      ValidationRequest<DateTime> request) _lastModified;

  @override
  FutureOr<Message> onCall(Request request) {
    return call(request);
  }

  @override
  FutureOr<ValidationResponse<DateTime>> lastModified(
          ValidationRequest<DateTime> request) =>
      _lastModified(request);
}

class _EtagState extends Endpoint with EtagMixin {
  _EtagState(this.call, this._etag);

  final FutureOr<Message> Function(Request request) call;

  ///
  final FutureOr<ValidationResponse<String>> Function(
      ValidationRequest<String> request) _etag;

  @override
  FutureOr<Message> onCall(Request request) {
    return call(request);
  }

  @override
  FutureOr<ValidationResponse<String>> etag(
          ValidationRequest<String> request) =>
      _etag(request);
}

///
mixin LastModifiedStateMixin<T extends StatefulEndpoint> on EndpointState<T> {
  ///
  FutureOr<ValidationResponse<DateTime>> lastModified(
      ValidationRequest<DateTime> request);
}

///
mixin EtagStateMixin<T extends StatefulEndpoint> on EndpointState<T> {
  ///
  FutureOr<ValidationResponse<String>> etag(ValidationRequest<String> request);
}

///
abstract class EndpointCallingWithCacheControl<T> extends EndpointCalling {
  ///
  EndpointCallingWithCacheControl(
      EndpointCallingBinding endpoint, this.validate)
      : super(endpoint);

  ///
  FutureOr<ValidationResponse<T>> Function(ValidationRequest<T> request)
  validate;

  @override
  FutureOr<Message> onCall(Request request) async {
    try {
      if (request is ValidationRequest<T>) {
        return validate(request);
      }
      return await binding.component.onCall(request);
    } on Exception {
      rethrow;
    }
  }
}

class _LastModifiedCalling extends EndpointCallingWithCacheControl<DateTime> {
  _LastModifiedCalling(EndpointCallingBinding endpoint)
      : super(endpoint, (endpoint.component as LastModifiedMixin).lastModified);
}

class _EtagCalling extends EndpointCallingWithCacheControl<String> {
  _EtagCalling(EndpointCallingBinding endpoint)
      : super(endpoint, (endpoint.component as EtagMixin).etag);
}

///
mixin LastModifiedMixin on Endpoint {
  ///
  FutureOr<ValidationResponse<DateTime>> lastModified(
      ValidationRequest<DateTime> request);
}

///
mixin EtagMixin on Endpoint {
  ///
  FutureOr<ValidationResponse<String>> etag(ValidationRequest<String> request);
}
