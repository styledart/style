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
import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';
import 'package:style_dart/src/style_base.dart';
import 'package:style_dart/style_dart.dart';
import 'package:style_test/style_test.dart';

void main() {
  var app = runService(AuthTestServer());

  var calling = app.findCalling.calling;
  group('authTest', () {
    String? token;
    test('create', () async {
      var res = await calling(TestRequest(
          agent: Agent.http,
          cause: Cause.clientRequest,
          context: app,
          path: '/create'));
      expect(res.body?.data, isA<String>());
      token = res.body?.data as String;
      expect((res as Response).statusCode, 200);
    });

    test('verify', () async {
      var res = await calling(TestRequest(
          agent: Agent.http,
          cause: Cause.clientRequest,
          context: app,
          body: token,
          path: '/verify'));
      expect(res.body?.data, isMap);
      expect((res as Response).statusCode, 200);
    });
  });
}

class AuthTestServer extends StatelessComponent {
  const AuthTestServer({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) => Server(
          // authorization: SimpleAuthorization(),
          dataAccess: DataAccess(SimpleCacheDataAccess()),
          cryptoService: MyEncHandler(
              tokenKey1: '11111111111111111111111111111111',
              tokenKey2: '11111111111111111111111111111111',
              tokenKey3: '11111111111111111111111111111111'),
          children: [
            // RouteBase("create", root: CreateTestToken()),
            RouteBase('verify', root: VerifyToken())
          ]);
}
//
// class CreateTestToken extends Endpoint {
//   CreateTestToken() : super();
//
//   @override
//   FutureOr<Object> onCall(Request request) async {
//     var token = AccessToken.create(
//         context: context,
//         subject: "test",
//         deviceID: "",
//         userId: "test_user",
//         expire: DateTime(2022));
//     return (await context.authorization.encryptToken(token));
//   }
// }

class VerifyToken extends Endpoint {
  VerifyToken() : super();

  @override
  FutureOr<Object> onCall(Request request) async {
    if (request.body is! StringBody) {
      throw BadRequests();
    }
    var res = await context.authorization
        .decryptToken((request.body as StringBody).data);
    return (res.toMap());
  }
}

class MyEncHandler extends Crypto {
  MyEncHandler(
      {required String tokenKey1,
      required String tokenKey2,
      required String tokenKey3})
      : tokenKey1 = SecretKey(utf8.encode(tokenKey1)),
        tokenKey2 = SecretKey(utf8.encode(tokenKey2)),
        tokenKey3 = SecretKey(utf8.encode(tokenKey3));

  SecretKey tokenKey1, tokenKey2, tokenKey3;

  @override
  Future<List<int>> calculateSha1Mac(List<int> plain) async {
    var dAlg = Hmac(Sha1());
    return (await dAlg.calculateMac(plain, secretKey: tokenKey3)).bytes;
  }

  @override
  Future<List<int>> calculateSha256Mac(List<int> plain) async {
    var cAlg = Hmac.sha256();

    return (await cAlg.calculateMac(plain, secretKey: tokenKey1)).bytes;
  }

  Future<List<int>> calculateSha256MacAlternative(List<int> plain) async {
    var cAlg = Hmac.sha256();

    return (await cAlg.calculateMac(plain, secretKey: tokenKey2)).bytes;
  }

  Future<String> decrypt1stStage(String cipher, Uint8List clientNonce) async {
    var split = cipher.split('.');
    if (split.length != 2) {
      throw Exception('Invalid cipher text');
    }
    var scBox = await algorithm.decrypt(
        SecretBox(base64Url.decode(split.last),
            nonce: clientNonce, mac: Mac(base64Url.decode(split.first))),
        secretKey: secretKey1);
    return utf8.decode(scBox);
  }

  final algorithm = DartXchacha20(macAlgorithm: Hmac.sha256());

  late SecretKey secretKey1;

  Future<String> encrypt1stStage(String plain, Uint8List clientNonce) async {
    var scBox = await algorithm.encrypt(utf8.encode(plain),
        secretKey: secretKey1, nonce: clientNonce);
    var en = '${base64Url.encode(scBox.mac.bytes)}'
        '.${base64Url.encode(scBox.cipherText)}';
    return en;
  }

  Future<String> encrypt2ndStage(String plain, Uint8List serverNonce) async {
    var scBox = await algorithm.encrypt(utf8.encode(plain),
        secretKey: secretKey1, nonce: serverNonce);
    var en = '${base64Url.encode(scBox.mac.bytes)}'
        '.${base64Url.encode(scBox.cipherText)}';
    return en;
  }

  Future<String> decrypt2ndStage(String cipher, Uint8List serverNonce) async {
    var split = cipher.split('.');
    if (split.length != 2) {
      throw Exception('Invalid cipher text');
    }
    var scBox = await algorithm.decrypt(
        SecretBox(base64Url.decode(split.last),
            nonce: serverNonce, mac: Mac(base64Url.decode(split.first))),
        secretKey: secretKey1);
    return utf8.decode(scBox);
  }

  int get nonceLength => 24;

  @override
  FutureOr<String> decrypt(
          String cipher, Uint8List clientNonce, Uint8List serverNonce) async =>
      decrypt2ndStage(await decrypt1stStage(cipher, clientNonce), serverNonce);

  @override
  FutureOr<String> encrypt(
          String plain, Uint8List clientNonce, Uint8List serverNonce) async =>
      encrypt2ndStage(await encrypt1stStage(plain, clientNonce), clientNonce);

  @override
  FutureOr<bool> init([bool inInterface = true]) => true;

  @override
  FutureOr<String> passwordHash(String clearText) {
    // TODO: implement passwordHash
    throw UnimplementedError();
  }
}
