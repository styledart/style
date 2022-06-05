/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

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
  Cacheability.public() : _name = 'public';

  ///
  Cacheability.private() : _name = 'private';

  ///
  Cacheability.noCache() : _name = 'no-cache';

  ///
  Cacheability.noStore() : _name = 'no-store';

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
  const Expiration.maxAge(this.duration) : _name = 'max-age';

  ///
  const Expiration.sMaxAge(this.duration) : _name = 's-max-age';

  ///
  const Expiration.maxStale(this.duration) : _name = 'max-stale';

  ///
  const Expiration.minFresh(this.duration) : _name = 'min-fresh';

  ///
  const Expiration.staleWhileRevalidation(this.duration)
      : _name = 'stale-while-revalidation';

  ///
  const Expiration.staleIfError(this.duration) : _name = 'stale-if-error';

  ///
  final Duration duration;

  ///
  final String _name;

  ///
  @override
  String get name => '$_name=${duration.inSeconds}';
}

///
class Revalidation extends CacheControlDirective {
  ///
  const Revalidation(this._name, this.method);

  ///
  const Revalidation.mustRevalidate(this.method) : _name = 'must-revalidate';

  ///
  const Revalidation.proxyRevalidate(this.method) : _name = 'proxy-revalidate';

  ///
  final String _name;

  ///
  final RevalidationMethod method;

  @override
  String get name => _name;
}

///
class ValidationResult {
  ///
  const ValidationResult.ok(
      {this.contentType, required this.headers, required this.statusCode})
      : valid = true,
        assert((statusCode != null && headers != null));

  ///
  const ValidationResult.not()
      : valid = false,
        statusCode = null,
        contentType = null,
        headers = null;

  ///
  final bool valid;

  ///
  final int? statusCode;

  ///
  final ContentType? contentType;

  ///
  final Map<String, dynamic>? headers;
}

///
abstract class RevalidationMethod<T> {
  ///
  late BuildContext context;

  ///
  ValidationResult validate(ValidationRequest<T> request, T? data);

  ///
  ValidationRequest<T> createRequest(Request request);

  FutureOr<Message> _validateAndReturn(Request request,
      FutureOr<Message> Function(Request request) childCalling) async {
    if (T == dynamic) {
      throw Exception();
    }

    var valReq = createRequest(request);

    var res = await childCalling(valReq);
    if (res is ValidationResponse<T>) {
      return res;
    } else if (res is ResponseWithCacheControl<T>) {
      var val = valReq.validate(res.validationData);
      if (val.valid) {
        return request.response(null,
            contentType: val.contentType,
            headers: val.headers,
            statusCode: val.statusCode);
      }
      return request.response(res.body,
          statusCode: res.statusCode,
          headers: res.additionalHeaders,
          contentType: res.contentType);
    } else {
      return res;
    }
  }
}

///
class IfModifiedSinceMethod extends RevalidationMethod<DateTime> {
  @override
  ValidationResult validate(
      covariant ValidationRequest<DateTime> request, covariant DateTime? data) {
    if (data == null || request.validationData == null) {
      return ValidationResult.not();
    }
    if (data.millisecondsSinceEpoch ~/ 1000 >
        request.validationData!.millisecondsSinceEpoch ~/ 1000) {
      return ValidationResult.not();
    } else {
      return ValidationResult.ok(
          // contentType: validationResponse.contentType,
          headers: {
            HttpHeaders.lastModifiedHeader: HttpDate.format(data),
            HttpHeaders.contentLengthHeader: 0
          }, statusCode: 304);
    }
  }

  static DateTime? _getIfModifiedSince(Map<String, List<String>>? headers) {
    var h = HttpHeaders.ifModifiedSinceHeader;
    if (headers != null && headers[h] != null && headers[h]!.isNotEmpty) {
      return HttpDate.parse(headers[h]!.first);
    }
    return null;
  }

  @override
  ValidationRequest<DateTime> createRequest(Request request) =>
      ValidationRequest<DateTime>.fromRequest(
          request, _getIfModifiedSince(request.headers), this);
}

///
class IfNoneMatchMethod extends RevalidationMethod<String> {
  @override
  ValidationResult validate(
      covariant ValidationRequest<String> request, covariant String? data) {
    if (data == null || request.validationData == null) {
      return ValidationResult.not();
    }
    if (data != request.validationData) {
      return ValidationResult.not();
    } else {
      return ValidationResult.ok(
          // contentType: validationResponse.contentType,
          headers: {
            HttpHeaders.etagHeader: data,
            HttpHeaders.contentLengthHeader: 0
          }, statusCode: 304);
    }
    //
    // if (request.validationData == validationResponse.value) {
    //   return ValidationResult.ok(headers: {
    //     HttpHeaders.etagHeader: validationResponse.value,
    //     HttpHeaders.contentLengthHeader: 0
    //   }, statusCode: 304);
    // } else {
    //   return ValidationResult.not();
    // }
  }

  @override
  ValidationRequest<String> createRequest(Request request) =>
      ValidationRequest.fromRequest(request,
          request.headers![HttpHeaders.ifNoneMatchHeader]?.first, this);
}

///
class ValidationRequest<T> extends Request {
  ///
  ValidationRequest.fromRequest(
      Request request, this.validationData, this.revalidationMethod)
      : super.fromRequest(request);

  ///
  T? validationData;

  ///
  // static ValidationRequest<TT>? create<TT>(
  //     Request request, BuildContext context, RevalidationMethod<TT> method) {
  //   if (_getIfModifiedSince(request.headers) != null && TT == DateTime) {
  //     return ValidationRequest<DateTime>.fromRequest(
  //         request,
  //         _getIfModifiedSince(request.headers)!,
  //         method as RevalidationMethod<DateTime>) as ValidationRequest<TT>;
  //   } else if (request.headers?[HttpHeaders.ifMatchHeader] != null &&
  //       TT == String) {
  //     return ValidationRequest<String>.fromRequest(
  //         request,
  //         request.headers![HttpHeaders.ifMatchHeader]!.first,
  //         method as RevalidationMethod<String>) as ValidationRequest<TT>;
  //   } else if (request.headers?[HttpHeaders.ifNoneMatchHeader] != null &&
  //       TT == String) {
  //     return ValidationRequest<String>.fromRequest(
  //         request,
  //         request.headers![HttpHeaders.ifNoneMatchHeader]!.first,
  //         method as RevalidationMethod<String>) as ValidationRequest<TT>;
  //   } else if (request.headers?[HttpHeaders.ifRangeHeader] != null &&
  //       TT == String) {
  //     return ValidationRequest<String>.fromRequest(
  //         request,
  //         request.headers![HttpHeaders.ifRangeHeader]!.first,
  //         method as RevalidationMethod<String>) as ValidationRequest<TT>;
  //   } else if (request.headers?[HttpHeaders.ifUnmodifiedSinceHeader]
  //   != null &&
  //       TT == DateTime) {
  //     return ValidationRequest<DateTime>.fromRequest(
  //         request,
  //         HttpDate.parse(
  //             request.headers![HttpHeaders.ifUnmodifiedSinceHeader]!.first),
  //         method as RevalidationMethod<DateTime>) as ValidationRequest<TT>;
  //   }
  // }

  ////
  RevalidationMethod<T> revalidationMethod;

  /// Return true the client has valid data
  /// Not need sent data.
  ///
  /// If valid return etag or last-modified
  ValidationResult validate(T? value) =>
      revalidationMethod.validate(this, value);
}

///
typedef ValidationCallback<T> = bool Function(T? value);

///
class ValidationResponse<T> extends ResponseWithCacheControl<T> {
  ///
  ValidationResponse(
      {required ValidationRequest<T> request,
      required this.value,
      required ValidationResult result,
      Map<String, dynamic>? additionalHeaders,
      int? statusCode,
      ContentType? contentType})
      : super._(null,
            request: request,
            validationData: value,
            additionalHeaders: (additionalHeaders ?? <String, dynamic>{})
              ..addAll(result.headers ?? {}),
            contentType: contentType,
            statusCode: statusCode ?? result.statusCode);

  ///
  T? value;
}

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
  Map<String, List<String>> get headers => {
        HttpHeaders.cacheControlHeader: [
          if (cacheability != null) cacheability!.name,
          if (expiration != null) expiration!.name,
          if (revalidation != null) revalidation!.name
        ],
      };
}

///
class CacheControl extends GateWithChild {
  ///
  factory CacheControl(
      {Cacheability? cacheability,
      Revalidation? revalidation,
      Expiration? expiration,
      required Component child}) {
    var cc = CacheControlBuilder(
        expiration: expiration,
        cacheability: cacheability,
        revalidation: revalidation);
    if (revalidation != null) {
      return _CacheControlWithRevalidation(child: child, cacheControl: cc);
    }

    return CacheControl._(cacheControl: cc, child: child);
  }

  ///
  CacheControl._({required this.cacheControl, required Component child})
      : super(child: child);

  ///
  final CacheControlBuilder cacheControl;

  @override
  SingleChildCallingBinding createBinding() => _CacheControlBinding(this);

  ///
  void addHeaders(Message response) {
    if (response is Response) {
      response.additionalHeaders ??= {};
      response.additionalHeaders!.addAll(cacheControl.headers);
    }
  }

  @override
  FutureOr<Message> onRequest(Request request,
      FutureOr<Message> Function(Request p1) childCalling) async {
    var res = await childCalling(request);
    addHeaders(res);
    return res;
  }
}

///
class _CacheControlWithRevalidation extends CacheControl {
  _CacheControlWithRevalidation(
      {required Component child, required CacheControlBuilder cacheControl})
      : assert(cacheControl.revalidation != null),
        super._(child: child, cacheControl: cacheControl);

  @override
  FutureOr<Message> onRequest(Request request,
      FutureOr<Message> Function(Request p1) childCalling) async {
    var r = await cacheControl.revalidation!.method
        ._validateAndReturn(request, childCalling);
    addHeaders(r);
    return r;
  }
}

///
abstract class ResponseWithCacheControl<T> extends Response {
  ///
  factory ResponseWithCacheControl(dynamic body,
      {required Request request, required T data}) {
    if (T == String) {
      return ResponseWithEtag(body, request: request, etag: data as String)
          as ResponseWithCacheControl<T>;
    }
    if (T == DateTime) {
      return ResponseWithLastModified(body,
          request: request,
          lastModified: data as DateTime) as ResponseWithCacheControl<T>;
    }
    throw UnimplementedError('Only String or DateTime implemented');
  }

  ///
  ResponseWithCacheControl._(Body? body,
      {required this.validationData,
      required Map<String, dynamic>? additionalHeaders,
      required Request request,
      int? statusCode,
      ContentType? contentType})
      : super(
            request: request,
            statusCode: statusCode ?? 200,
            additionalHeaders: additionalHeaders,
            body: body,
            contentType: contentType);

  ///
  T? validationData;
}

///
class ResponseWithLastModified extends ResponseWithCacheControl<DateTime> {
  ///
  ResponseWithLastModified(dynamic body,
      {Map<String, dynamic>? additionalHeaders,
      required Request request,
      required DateTime? lastModified,
      int? statusCode,
      ContentType? contentType})
      : super._(
            body is Body
                ? body
                : body != null
                    ? Body(body)
                    : null,
            validationData: lastModified,
            request: request,
            contentType: contentType,
            statusCode: statusCode ?? 200,
            additionalHeaders: (additionalHeaders ?? <String, dynamic>{})
              ..addAll({
                if (lastModified != null)
                  HttpHeaders.lastModifiedHeader: HttpDate.format(lastModified)
              }));
}

///
class ResponseWithEtag extends ResponseWithCacheControl<String> {
  ///
  ResponseWithEtag(dynamic body,
      {Map<String, dynamic>? additionalHeaders,
      required Request request,
      required String? etag,
      int? statusCode,
      ContentType? contentType})
      : super._(
            body is Body
                ? body
                : body != null
                    ? Body(body)
                    : null,
            validationData: etag,
            request: request,
            contentType: contentType,
            statusCode: statusCode ?? 200,
            additionalHeaders: (additionalHeaders ?? <String, dynamic>{})
              ..addAll({if (etag != null) HttpHeaders.etagHeader: etag}));
}

///
class _CacheControlBinding extends SingleChildCallingBinding {
  _CacheControlBinding(CacheControl component) : super(component);

  @override
  CacheControl get component => super.component as CacheControl;

  @override
  void buildBinding() {
    super.buildBinding();

    if (component.cacheControl.revalidation?.method != null) {
      var ends = <EndpointCallingBinding>[];

      visitChildren(TreeVisitor((visitor) {
        if (visitor.currentValue is EndpointCallingBinding) {
          ends.add(visitor.currentValue as EndpointCallingBinding);
        }
      }));

      if (component.cacheControl.revalidation?.method
          is RevalidationMethod<DateTime>) {
        var nonCaches = ends.where((e) => e.component is! LastModifiedEndpoint);
        if (nonCaches.isNotEmpty) {
          throw UnsupportedError("All cache control's children on "
              'the tree must be cache control endpoint.'
              ' You can define cache control endpoint with use mixins:'
              'Also endpoints cache control types must '
              'match revalidation method'
              '\nLastModifiedMixin\nLastModifiedStateMixin'
              '\nEtagMixin\nEtagStateMixin'
              '\n${nonCaches.map((e) => e.component).toList()} '
              'is not cache control or type not match');
        }
      }

      if (component.cacheControl.revalidation?.method
          is RevalidationMethod<String>) {
        var nonCaches = ends.where((e) => e.component is! EtagEndpoint);
        if (nonCaches.isNotEmpty) {
          throw UnsupportedError("All cache control's children on "
              'the tree must be cache control endpoint.'
              ' You can define cache control endpoint with use mixins:'
              'Also endpoints cache control types must '
              'match revalidation method'
              '\nLastModifiedMixin\nLastModifiedStateMixin'
              '\nEtagMixin\nEtagStateMixin'
              '\n${nonCaches.map((e) => e.component).toList()}'
              ' is not cache control or type not match');
        }
      }
    }
  }

  @override
  void attachToParent(Binding parent) {
    (component).cacheControl.revalidation?.method.context = this;
    super.attachToParent(parent);
  }
}
