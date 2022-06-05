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

import 'package:style_dart/style_dart.dart';
import 'package:test/expect.dart';

/// [bodyIs] checks the response body.
///
/// if [bodyOrMatcher] is matcher [bodyIs] creates a
/// [_CustomBodyMatcher] instance, else creates [_BodyMatcher]
/// instance and checks the response body with these matchers.
///
/// Example:
///
/// ````dart
/// tester("/path/to" , bodyIs({"hello" : "world"}))
/// ````
///
/// native equals:
///
/// ````dart
/// //.. get response
/// test(response.body, eq({"hello" : "world"}))
/// ````
///
/// OR use with matcher
///
///
/// ````dart
/// tester("/path/to" , bodyIs(contains("hello")))
/// ````
///
/// native equals:
///
/// ````dart
/// //.. get response
/// test(response.body, contains("hello"))
/// ````
Matcher bodyIs(dynamic bodyOrMatcher) {
  if (bodyOrMatcher is Matcher) {
    return _CustomBodyMatcher._(bodyOrMatcher);
  }
  return _BodyMatcher._(bodyOrMatcher);
}

/// StatusCodeMatcher checks status code of the response.
///
/// Example:
///
/// ````dart
/// tester("/path/to" , statusCodeIs(500))
/// ````
///
/// native equals:
///
/// ````dart
/// //.. get response
/// test(response.statusCode, 500)
/// ````
_ExactStatusCodeMatcher statusCodeIs(int statusCode) =>
    _ExactStatusCodeMatcher._(statusCode);

/// Check status code is 401.
///
/// Server has not take any authorization
_ExactStatusCodeMatcher isUnauthorized = statusCodeIs(401);

/// Check status code is 403 (Forbidden Unauthorization Error).
///
/// Server take authorization but the client does not have a access
/// for the content.
_ExactStatusCodeMatcher permissionIsDenied = statusCodeIs(403);

/// Check status code is in range
_RangeStatusCodeMatcher statusCodeIsInRange(int min, int max) =>
    _RangeStatusCodeMatcher._(min, max);

/// Status code is between 100-199
_RangeStatusCodeMatcher isInformational = statusCodeIsInRange(100, 200);

/// Status code is between 200-299
_RangeStatusCodeMatcher isSuccess = statusCodeIsInRange(200, 300);

/// Status code is between 300-399
_RangeStatusCodeMatcher isRedirection = statusCodeIsInRange(300, 400);

/// Status code is between 400-499
_RangeStatusCodeMatcher isClientError = statusCodeIsInRange(400, 500);

/// Status code is between 500-599
_RangeStatusCodeMatcher isServerError = statusCodeIsInRange(500, 600);

/// [headerIs] checks response headers key => value pairs.
/// header can be null or List. So your matcher must be according to
/// Iterable matchers.
///
/// eg. your matcher can be:
///
/// equals(["must-revalidate"])
///
/// or
///
/// contains("must-revalidate")
///
///
_HeaderMatcher headerIs(String key, Matcher value) =>
    _HeaderMatcher._(key, value);

/// Request matcher checks the response.
abstract class _ResponseMatcher extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Response) {
      return false;
    } else {
      return match(item);
    }
  }

  bool match(Response response);
}

/// BodyMatcher checks the response body with "eq" matcher.
class _BodyMatcher extends _ResponseMatcher {
  /// Body must not be matcher.
  /// if body is matcher use CustomBodyMatcher instead.
  _BodyMatcher._(this.body);

  dynamic body;

  @override
  Description describe(Description description) {
    return description.add("body is : $body ");
  }

  @override
  bool match(Response response) {
    return equals(body).matches(response.body?.data, {});
  }

  @override
  Description describeMismatch(dynamic item, Description mismatchDescription,
      Map matchState, bool verbose) {
    return mismatchDescription
        .add("body: ")
        .add((item is Response) ? "${item.body?.data} " : "$item ");
  }
}

/// CustomBodyMatcher matcher checks the response body with given [matcher].
class _CustomBodyMatcher extends _ResponseMatcher {
  _CustomBodyMatcher._(this.matcher);

  Matcher matcher;

  @override
  Description describe(Description description) {
    return description.add(matcher.describe(description).toString());
  }

  @override
  bool match(Response response) {
    return matcher.matches(response.body?.data, {});
  }
}

/// StatusCodeMatcher checks status code of the response.
abstract class _StatusCodeMatcher extends _ResponseMatcher {
  @override
  Description describe(Description description) {
    return description.add("status_code: ");
  }

  bool check(int statusCode);

  @override
  bool match(Response response) {
    return check(response.statusCode);
  }

  @override
  Description describeMismatch(dynamic item, Description mismatchDescription,
      Map matchState, bool verbose) {
    return mismatchDescription
        .add("status_code: ")
        .add((item is Response) ? "${item.statusCode} " : "$item ");
  }
}

/// ExactStatusCodeMatcher checks status code of the response.
/// Checks exactly.
class _ExactStatusCodeMatcher extends _StatusCodeMatcher {
  _ExactStatusCodeMatcher._(this.statusCode);

  /// Http status code
  int statusCode;

  @override
  bool check(int statusCode) {
    return statusCode == this.statusCode;
  }

  @override
  Description describe(Description description) {
    return super.describe(description)..add(statusCode.toString());
  }
}

/// RangeStatusCodeMatcher checks status code of the response.
/// Checks is in range.
class _RangeStatusCodeMatcher extends _StatusCodeMatcher {
  /// min include, max exclude
  _RangeStatusCodeMatcher._(this.min, this.max);

  ///
  int min, max;

  @override
  bool check(int statusCode) {
    return (min <= statusCode && statusCode < max);
  }

  @override
  Description describe(Description description) {
    return super.describe(description)..add(" $min <= code < $max ");
  }
}

/// HeaderMatcher checks header of the response.
class _HeaderMatcher extends _ResponseMatcher {
  _HeaderMatcher._(this.key, this.value);

  String key;
  Matcher value;

  @override
  Description describeMismatch(dynamic item, Description mismatchDescription,
      Map matchState, bool verbose) {
    return mismatchDescription
        .add("header: ")
        .add((item is Response) ? "${item.additionalHeaders} " : "$item ");
  }

  @override
  Description describe(Description description) {
    return description..add("header $key match ${value.describe(description)}");
  }

  @override
  bool match(Response response) {
    return equals(value).matches(response.additionalHeaders?[key], {});
  }
}
