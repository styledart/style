/*
 * Copyright (c) 2021. This code was written by Mehmet Yaz.
 * Mehmet Yaz does not accept the problems that may arise due to these codes.
 */

import 'dart:io';

import 'package:style_dart/style_dart.dart';
import 'package:style_test/src/requests.dart';
import 'package:test/test.dart';

class ResponseTest {
  ResponseTest(this.binding);

  Binding binding;

  bool initChecked = false;

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
      if (!initChecked) {
        ///
        var initializers = <Future<bool>>[];
        if (binding.hasService<DataAccess>()) {
          initializers.add(binding.dataAccess.ensureInitialize().then((value) {
            print("Data Access Initialize $value");
            return value;
          }));
        }
        if (binding.hasService<HttpService>()) {
          initializers.add(binding.httpService.ensureInitialize().then((value) {
            print("HttpService Initialize $value");
            return value;
          }));
        }
        if (binding.hasService<WebSocketService>()) {
          initializers
              .add(binding.socketService.ensureInitialize().then((value) {
            print("Socket Initialize $value");
            return value;
          }));
        }
        if (binding.hasService<Logger>()) {
          initializers.add(binding.logger.ensureInitialize().then((value) {
            print("Logger Initialize $value");
            return value;
          }));
        }
        if (binding.hasService<Crypto>()) {
          initializers.add(binding.crypto.ensureInitialize().then((value) {
            print("Crypto Initialize $value");
            return value;
          }));
        }

        var r = await Future.wait(initializers);
        expect(r, isNot(contains(false)));
        initChecked = true;
      }
      expect(await binding.findCalling.calling(req), matcher, skip: false);
    });
  }
}
