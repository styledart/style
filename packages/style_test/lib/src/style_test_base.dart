import 'dart:io';

import 'package:meta/meta.dart';
import 'package:style_dart/style_dart.dart';
import 'package:style_test/src/test_response.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

typedef _Tester = void Function(
  String path,
  Matcher matcher, {
  Agent? agent,
  Cause? cause,
  String? description,
  Methods? methods,
  dynamic body,
  List<Cookie>? cookies,
  ContentType? contentType,
  Map<String, dynamic>? headers,
});

@visibleForTesting
Future<void> initStyleTester(String groupName, Component server,
    void Function(_Tester tester) testRequest) async {
  var app = runService(server);


  var respTest = ResponseTest(app);
  group(groupName, () {
    testRequest(respTest.testRequest);
  });
}
