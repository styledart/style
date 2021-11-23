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

part of '../../style_base.dart';

///
abstract class Authorization extends _BaseService {
  ///
  Authorization();

  ///
  static Authorization of(BuildContext context){
    return context.authorization;
  }

  ///
  FutureOr<bool> initService();

  ///
  FutureOr<AccessToken> login(dynamic authData);

  ///
  FutureOr<bool> logout(dynamic authData);

  ///
  FutureOr<AccessToken> register(dynamic authData);

  ///
  FutureOr<AccessToken> verifyToken(String token);

  ///
  FutureOr<String> decryptToken(AccessToken token);

  ///
  Crypto get crypto => _crypto ??= context.crypto;

  ///
  Crypto? _crypto;

  ///
  DataAccess get dataAccess => _dataAccess ??= context.dataAccess;

  ///
  DataAccess? _dataAccess;

  @override
  FutureOr<bool> init([bool inInterface = true]) {
    if (!context.hasService<Crypto>()) {
      throw UnsupportedError("Authorization service not"
          " supported without CryptoService");
    }

    if (!context.hasService<DataAccess>()) {
      throw UnsupportedError("Authorization service not"
          " supported without CryptoService");
    }
    return initService();
  }
}












///
class SimpleAuthorization extends Authorization {
  @override
  FutureOr<bool> initService() {
    return true;
  }

  @override
  FutureOr<AccessToken> login(dynamic authData) {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  FutureOr<bool> logout(dynamic authData) {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  FutureOr<AccessToken> register(dynamic authData) {
    // TODO: implement register
    throw UnimplementedError();
  }

  @override
  FutureOr<String> decryptToken(AccessToken token) async {
    var header = <String, dynamic>{"alg": "HS256", "typ": "JWT"};
    var payload = token.toMap();

    var base64Payload = base64Url.encode(utf8.encode(json.encode(payload)));

    var base64Header = base64Url.encode(utf8.encode(json.encode(header)));

    ///
    var cT = "$base64Header.$base64Payload";

    ///
    var hash = await crypto.calculateSha256Mac(utf8.encode(cT));

    return "$cT.${base64Url.encode(hash)}";
  }

  @override
  FutureOr<AccessToken> verifyToken(String token) async {
    var parts = token.split(".");
    if (parts.length != 3) {
      throw UnauthorizedException();
    }

    var headerText = parts[0];
    var payloadText = parts[1];
    var hashBase64 = parts[2];


    var calcHash = await crypto
        .calculateSha256Mac(utf8.encode("$headerText.$payloadText"));

    var calcHashBase64 = base64Url.encode(calcHash);

    if (calcHashBase64 != hashBase64) {
      throw UnauthorizedException();
    }

    return AccessToken.fromMap(
        json.decode(utf8.decode(base64Url.decode(payloadText))));
  }
}
