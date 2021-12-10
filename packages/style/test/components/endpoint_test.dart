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

import 'dart:async';

import 'package:style_dart/style_dart.dart';
import 'package:style_test/style_test.dart';

void main() async {
  /// The test for endpoint return types include
  /// with and without preferred type option.
  var bindTester =
      await initStyleTester("endpoints", _MyServer(), (tester) async {
    /// Default Endpoint
    group("default_endpoint", () {
      tester("/normal/any", bodyIs("String"));
      tester("/normal/any_ftr", bodyIs("String"));
      tester("/normal/map", bodyIs({"map": true}));
      tester("/normal/body", bodyIs("body"));
      tester("/normal/body_ftr", bodyIs("body"));
      tester("/normal/message", bodyIs("message"));
      tester("/normal/message_ftr", bodyIs("message"));
      tester("/normal/db_res", bodyIs({"db_res": true}));
      tester("/normal/db_res_ftr", bodyIs({"db_res": true}));
      tester("/normal/access", bodyIs({"id": "veli"}));
      tester("/normal/access_ftr", bodyIs({"id": "veli"}));
    });

    /// Default Endpoint
    group("preferred_endpoints", () {
      tester("/any", bodyIs("any"));
      tester("/body", bodyIs("body"));
      tester("/body/future", bodyIs("body"));
      tester("/message", bodyIs("message"));
      tester("/message/future", bodyIs("message"));
      tester("/db", bodyIs({"id": "veli"}));
      tester("/db/future", bodyIs({"id": "veli"}));
      tester("/access", bodyIs({"id": "veli"}));
      tester("/access/future", bodyIs({"id": "veli"}));
    });
  });

  var defaultW = Stopwatch()..start();

  for (var i = 0; i < 20000; i++) {
    await bindTester(TestRequest(
        agent: Agent.http, cause: Cause.clientRequest, path: "/normal/any"));
  }
  defaultW.stop();
  var preferredW = Stopwatch()..start();
  for (var i = 0; i < 20000; i++) {
    await bindTester(TestRequest(
        agent: Agent.http, cause: Cause.clientRequest, path: "/any"));
  }
  preferredW.stop();

  test("optimized", () {
    expect(defaultW.elapsedMilliseconds > preferredW.elapsedMilliseconds, true);
  });
}

class MyServer extends StatelessComponent {
  const MyServer({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) {
    return Server(children: [
      CallQueue(MyStatefulEndpoint()),
      Route("hello", root: MyEndpoint(1)),
      Route("another",
          child: Route("sub-route",
              root: MyEndpoint(2),
              child: Route("second-sub", root: MyEndpoint(3))))
    ]);
  }
}

class MyStatefulEndpoint extends StatefulEndpoint {
  @override
  EndpointState<StatefulEndpoint> createState() => _MyStatefulEndpointState();
}

class _MyStatefulEndpointState extends EndpointState<MyStatefulEndpoint> {
  int counter = 0;

  @override
  FutureOr<Object> onCall(Request request) {
    counter++;
    return counter;
  }
}

class MyLastModifiedEndpoint extends LastModifiedEndpoint {
  @override
  FutureOr<ResponseWithCacheControl<DateTime>> onRequest(
      ValidationRequest<DateTime> request) {
    return ResponseWithLastModified("Hello",
        request: request, lastModified: DateTime.now());
  }
}

class _MyServer extends StatelessComponent {
  const _MyServer({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) {
    return Server(
        dataAccess:
            DataAccess(SimpleDataAccess("/home/mehmet/projects/style/packages/style/data/")),
        children: [
          Route("normal", handleUnknownAsRoot: true, root: DefaultEndpoint()),
          Route("any", handleUnknownAsRoot: true, root: AnyEndpoint()),
          Route("body", handleUnknownAsRoot: true, root: BodyEndpoint()),
          Route("access", handleUnknownAsRoot: true, root: AccessEndpoint()),
          Route("db", handleUnknownAsRoot: true, root: DbResEndpoint()),
          Route("message", handleUnknownAsRoot: true, root: MessageEndpoint()),
          Route("not_preferred",
              handleUnknownAsRoot: true, root: NotPreferredAny()),
        ]);
  }
}

///
class MyEndpoint extends Endpoint {
  MyEndpoint(this.code);

  final int code;

  @override
  FutureOr<Object> onCall(Request request) {
    return "Hello World! $code";
  }
}

class DefaultEndpoint extends Endpoint {
  DefaultEndpoint() : super();

  @override
  FutureOr<Object> onCall(Request request) async {
    if (request.path.next == "any") {
      return "String";
    } else if (request.path.next == "any_ftr") {
      return Future.value("String");
    } else if (request.path.next == "map") {
      return {"map": true};
    } else if (request.path.next == "body") {
      return Body("body");
    } else if (request.path.next == "body_ftr") {
      return Future.value(Body("body"));
    } else if (request.path.next == "message") {
      return request.response(Body("message"));
    } else if (request.path.next == "message_ftr") {
      return Future.value(request.response(Body("message")));
    } else if (request.path.next == "db_res") {
      return DbResult<Map<String, dynamic>>(data: {"db_res": true});
    } else if (request.path.next == "db_res_ftr") {
      return Future.value(
          DbResult<Map<String, dynamic>>(data: {"db_res": true}));
    } else if (request.path.next == "access") {
      return Read(request: request, collection: "greeters", identifier: "veli");
    } else if (request.path.next == "access_ftr") {
      return Future.value(
          Read(request: request, collection: "greeters", identifier: "veli"));
    }
    return "${request.path.next}";
  }
}

class AnyEndpoint extends Endpoint {
  AnyEndpoint() : super();

  @override
  EndpointPreferredType? get preferredType =>
      EndpointPreferredType.anyEncodable;

  @override
  FutureOr<Object> onCall(Request request) {
    return "any";
  }
}

/// For optimization test
class NotPreferredAny extends Endpoint {
  NotPreferredAny() : super();

  @override
  FutureOr<Object> onCall(Request request) {
    return "any";
  }
}

class BodyEndpoint extends Endpoint {
  BodyEndpoint() : super();

  @override
  EndpointPreferredType? get preferredType => EndpointPreferredType.body;

  @override
  FutureOr<Object> onCall(Request request) {
    if (request.path.next == "future") {
      return Future.value(Body("body"));
    }
    return Body("body");
  }
}

class AccessEndpoint extends Endpoint {
  AccessEndpoint() : super();

  @override
  EndpointPreferredType? get preferredType => EndpointPreferredType.accessEvent;

  @override
  FutureOr<Object> onCall(Request request) {
    if (request.path.next == "future") {
      return Future.value(Read(collection: "greeters", identifier: "veli"));
    }


    return (Read(collection: "greeters", identifier: "veli"));
  }
}

class DbResEndpoint extends Endpoint {
  DbResEndpoint() : super();

  @override
  EndpointPreferredType? get preferredType => EndpointPreferredType.dbResult;

  @override
  FutureOr<Object> onCall(Request request) async {
    if (request.path.next == "future") {
      return DataAccess.of(context).read(
          Read(request: request, collection: "greeters", identifier: "veli"));
    }
    return await DataAccess.of(context).read(
        Read(request: request, collection: "greeters", identifier: "veli"));
  }
}

class MessageEndpoint extends Endpoint {
  MessageEndpoint() : super();

  @override
  EndpointPreferredType? get preferredType => EndpointPreferredType.response;

  @override
  FutureOr<Object> onCall(Request request) async {
    if (request.path.next == "future") {
      return request.response(Body("message"));
    }
    return await request.response(Body("message"));
  }
}
