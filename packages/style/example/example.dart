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

/// in example

class BerberServer extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Server(
      rootName: "berber_server",
      rootEndpoint: Redirect('../home'),
      children: [
        // TODO:
      ],
    );
  }
}

class BerberUnknownRequest extends Endpoint {
  @override
  FutureOr<Message> onCall(Request request) {
    // TODO: implement onCall
    throw UnimplementedError();
  }
}



class MMM extends LastModifiedEndpoint {
  /// If your data and lastModified are on different sources
  /// may you want to ensure that data is need(data changed after lastModified)
  /// before getting data from db.
  /// For this, you can check [ValidationResponse] documentation.
  @override
  FutureOr<ResponseWithCacheControl<DateTime>> onRequest(
      ValidationRequest<DateTime> request) {
    // TODO: set [body] and [lastModified] with your data.
    return ResponseWithLastModified("unimplemented",
        request: request, lastModified: DateTime.now());
  }
}


class EEEE extends EtagEndpoint {

  ///


  /// If your data and etag are on different sources
  /// may you want to ensure data need(e-tags are different)
  /// before get data from db.
  /// For this, you can check [ValidationResponse] documentation.
  @override
  FutureOr<ResponseWithCacheControl<String>> onRequest(
      ValidationRequest<String> request) {
    // TODO: set body and etag with your data.
    return ResponseWithEtag("unimplemented", request: request, etag: "etag");
  }
}



class MyStLastModd extends StatefulEndpoint {
  @override
  EndpointState<StatefulEndpoint> createState() => _MyStLastModdState();
}

class _MyStLastModdState extends LastModifiedEndpointState<MyStLastModd> {

  /// If your data and lastModified are on different sources
  /// may you want to ensure that data is need(data changed after lastModified)
  /// before getting data from db.
  /// For this, you can check [ValidationResponse] documentation.
  @override
  FutureOr<ResponseWithLastModified> onRequest(
      ValidationRequest<DateTime> request) {
    // TODO: set [body] and [lastModified] with your data.
    return ResponseWithLastModified("unimplemented",
        request: request, lastModified: DateTime.now());
  }
}


class MyETagEnd extends StatefulEndpoint {
  @override
  EndpointState<StatefulEndpoint> createState() => _MyETagEndState();
}

class _MyETagEndState extends EtagEndpointState<MyETagEnd> {


  /// If your data and etag are on different sources
  /// may you want to ensure data need(e-tags are different)
  /// before get data from db.
  /// For this, you can check [ValidationResponse] documentation.
  @override
  FutureOr<ResponseWithEtag> onRequest(ValidationRequest<String> request) {
    // TODO: set body and etag with your data.
    return ResponseWithEtag("unimplemented", request: request, etag: "etag");
  }
}



