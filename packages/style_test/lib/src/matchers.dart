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

abstract class RequestMatcher extends Matcher {
  @override
  bool matches(item, Map matchState) {
    if (item is! Response) {
      return false;
    } else {
      return match(item);
    }
  }

  bool match(Response response);
}

Matcher bodyIs(dynamic bodyOrMatcher) {
  if (bodyOrMatcher is Matcher) {
    return CustomBodyMatcher(bodyOrMatcher);
  }
  return BodyMatcher(bodyOrMatcher);
}

class BodyMatcher extends RequestMatcher {
  BodyMatcher(this.body);

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
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    return mismatchDescription
        .add("body: ")
        .add((item is Response) ? "${item.body?.data} " : "$item ");
  }
}

class CustomBodyMatcher extends RequestMatcher {
  CustomBodyMatcher(this.matcher);

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

class StatusCodeMatcher extends RequestMatcher {
  StatusCodeMatcher(this.statusCode);

  ///
  int statusCode;

  @override
  Description describe(Description description) {
    return description.add("status_code: " + statusCode.toString() + " ");
  }

  @override
  bool match(Response response) {
    return response.statusCode == statusCode;
  }

  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    return mismatchDescription
        .add("status_code: ")
        .add((item is Response) ? "${item.statusCode} " : "$item ");
  }
}

class HeaderMatcher extends RequestMatcher {
  HeaderMatcher(this.key, this.value);

  String key;
  String value;

  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    return mismatchDescription
        .add("header: ")
        .add((item is Response) ? "${item.additionalHeaders} " : "$item ");
  }

  @override
  Description describe(Description description) {
    return description..add("header $key contains all of $value");
  }

  @override
  bool match(Response response) {
    return equals(value).matches(response.additionalHeaders?[key], {});
  }
}


HeaderMatcher headerIs(String key, dynamic value) => HeaderMatcher(key, value);

StatusCodeMatcher statusCodeIs(int statusCode) => StatusCodeMatcher(statusCode);

UnauthorizedMatcher isUnauthorized = UnauthorizedMatcher();


class UnauthorizedMatcher extends StatusCodeMatcher {
  UnauthorizedMatcher() : super(401);
}

PermissionDenied permissionIsDenied = PermissionDenied();

class PermissionDenied extends StatusCodeMatcher {
  PermissionDenied() : super(403);
}
