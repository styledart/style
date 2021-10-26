/*
 * Copyright (c) 2021. This code was written by Mehmet Yaz.
 * Mehmet Yaz does not accept the problems that may arise due to these codes.
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
    return description;
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

StatusCodeMatcher statusCodeIs(int statusCode) => StatusCodeMatcher(statusCode);

UnauthorizedMatcher isUnauthorized = UnauthorizedMatcher();

class UnauthorizedMatcher extends StatusCodeMatcher {
  UnauthorizedMatcher() : super(401);
}

PermissionDenied permissionIsDenied = PermissionDenied();

class PermissionDenied extends StatusCodeMatcher {
  PermissionDenied() : super(403);
}
