/*
 * Copyright (c) 2021. This code was written by Mehmet Yaz.
 * Mehmet Yaz does not accept the problems that may arise due to these codes.
 */

import 'dart:io';

import 'package:style_dart/style_dart.dart';

class TestRequest extends Request {
  TestRequest({
    required Agent agent,
    required Cause cause,
    required BuildContext context,
    required String path,
    Map<String, dynamic>? headers,
    dynamic body,
    Methods? methods,
    List<Cookie>? cookies,
    ContentType? contentType,
  }) : super(
            context: RequestContext(
                agent: agent,
                cause: cause,
                createContext: context,
                pathController: PathController.fromFullPath(path),
                requestTime: DateTime.now(),
                accessToken: _getToken(headers)),
            body: body != null ? Body(body) : null,
            method: methods,
            cookies: cookies,
            contentType: contentType,
            headers: headers?.map((key, value) => MapEntry(
                key,
                value is List
                    ? value.map((e) => e.toString()).toList()
                    : <String>[value.toString()])));


  static String? _getToken(Map<String,dynamic>? headers) {
    if (headers == null) return null;
    var authH = headers[HttpHeaders.authorizationHeader];
    if (authH == null) return null;
    if (authH is List) {
      if (authH.isEmpty) return null;
      return authH.first;
    } else if (authH is String){
      return authH;
    }
  }

}
