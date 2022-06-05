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
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:style_dart/style_dart.dart';
import '../style_test.dart';

///
@visibleForTesting
Future<FutureOr<Message> Function(Request request)> initStyleTester(
    String groupName,
    Component server,
    Future<void> Function(
            FutureOr<void> Function(String, Matcher,
                    {Agent? agent,
                    Cause? cause,
                    String? description,
                    Methods? methods,
                    dynamic body,
                    List<Cookie>? cookies,
                    ContentType? contentType,
                    Map<String, dynamic>? headers})
                tester)
        tester) async {
  var app = runService(server);

  var respTest = ResponseTest(app);
  var init = await respTest.init();
  test("init", () {
    expect(init, true);
  });
  group(groupName, () {
    tester(respTest.testRequest);
  });

  return app.findCalling.calling.call;
}
