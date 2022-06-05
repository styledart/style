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

///
class TestRequest extends Request {
  ///
  TestRequest({
    required Agent agent,
    required Cause cause,
    BuildContext? context,
    required String path,
    Map<String, dynamic>? headers,
    dynamic body,
    Methods? methods,
    List<Cookie>? cookies,
    ContentType? contentType,
    AccessToken? token,
  }) : super(
            context: RequestContext(
                agent: agent,
                cause: cause,
                // createContext: context,
                pathController: PathController.fromFullPath(path),
                requestTime: DateTime.now(),
                accessToken: token),
            body: body != null ? Body(body) : null,
            method: methods,
            cookies: cookies,
            contentType: contentType,
            headers: headers?.map((key, value) => MapEntry(
                key,
                value is List
                    ? value.map((e) => e.toString()).toList()
                    : <String>[value.toString()])));
}
