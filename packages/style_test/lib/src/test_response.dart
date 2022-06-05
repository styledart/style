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

import 'dart:io';

import 'package:style_dart/style_dart.dart';
import 'package:test/test.dart';

import 'requests.dart';

///
class ResponseTest {
  ///
  ResponseTest(this.binding);

  ///
  Binding binding;

  ///
  bool initChecked = false;

  ///
  Future<bool> init() async {
    if (!initChecked) {
      ///
      var initializers = <Future<bool>>[];
      if (binding.hasService<DataAccess>()) {
        initializers.add(binding.dataAccess
                .ensureInitialize() /*.then((value) {
            print("Data Access Initialize $value");
            return value;
          })*/
            );
      }
      if (binding.hasService<HttpService>()) {
        initializers.add(binding.httpService
                .ensureInitialize() /*.then((value) {
            print("HttpService Initialize $value");
            return value;
          })*/
            );
      }
      if (binding.hasService<WebSocketService>()) {
        initializers.add(binding.socketService
                .ensureInitialize() /*.then((value) {
            print("Socket Initialize $value");
            return value;
          })*/
            );
      }
      if (binding.hasService<Logger>()) {
        initializers.add(binding.logger
                .ensureInitialize() /*.then((value) {
            print("Logger Initialize $value");
            return value;
          })*/
            );
      }
      if (binding.hasService<Crypto>()) {
        initializers.add(binding.crypto
                .ensureInitialize() /*.then((value) {
            print("Crypto Initialize $value");
            return value;
          })*/
            );
      }
      var r = await Future.wait(initializers);
      initChecked = true;
      return !r.contains(false);
    }
    return true;
  }

  ///
  void testRequest(
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
  }) {
    var req = TestRequest(
        agent: agent ?? Agent.http,
        headers: headers,
        cause: cause ?? Cause.clientRequest,
        context: binding,
        methods: methods,
        contentType: contentType,
        body: body,
        cookies: cookies,
        path: path);

    test(description ?? "testing: ${req.path.calledPath}", () async {
      expect(await binding.findCalling.calling(req), matcher, skip: false);
    });
  }
}
