/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE,
 *    Version 3 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       https://www.gnu.org/licenses/agpl-3.0.en.html
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

part of '../../../style_base.dart';

//TODO: Set New Task

///
abstract class Authorization extends BaseService {
  ///
  Authorization({List<Confirmatory>? confirmatories})
      : _confirmatories = (confirmatories ?? [])
            .asMap()
            .map((key, value) => MapEntry(value.key.key, value));

  ///
  static Authorization of(BuildContext context) => context.authorization;

  ///
  FutureOr<bool> initService();

  ///
  FutureOr<dynamic> login(dynamic authData);

  ///
  FutureOr<void> logout(dynamic authData);

  ///
  FutureOr<AccessToken> register(dynamic authData, {dynamic credentials});

  ///
  FutureOr<AccessToken> decryptToken(String token);

  ///
  FutureOr<String> encryptToken(AccessToken token);

  /// throw if token not verified
  FutureOr<void> verifyToken(AccessToken token);

  ///
  Component build(BuildContext context);

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
      throw UnsupportedError('Authorization service not'
          ' supported without CryptoService');
    }

    if (!context.hasService<DataAccess>()) {
      throw UnsupportedError('Authorization service not'
          ' supported without DataAccess');
    }

    _confirmatories.forEach((key, value) {
      value._attach(context);
    });

    return initService();
  }

  ///
  final Map<String, Confirmatory> _confirmatories;

  ///
  Confirmatory getConfirmatoryByKey(String key) => _confirmatories[key]!;

  ///
  T getConfirmatory<T extends Confirmatory>(ConfirmationType type) {
    var available = _confirmatories.values
        .whereType<T>()
        .where((element) => element.type == type);

    if (available.isEmpty) {
      throw ServiceUnavailable("There isn't available confirmatory");
    }

    if (available.length > 1) {
      throw ServiceUnavailable('There multiple available confirmatory.'
          ' use [confirmatoryByKey].');
    }

    return available.first;
  }
}

///
// class SimpleAuthorization extends Authorization {
//   @override
//   FutureOr<bool> initService() {
//     return true;
//   }
//
//   @override
//   FutureOr<UserCredential> login(dynamic authData) {
//     // TODO: implement login
//     throw UnimplementedError();
//   }
//
//   @override
//   FutureOr<bool> logout(dynamic authData) {
//     // TODO: implement logout
//     throw UnimplementedError();
//   }
//
//   @override
//   FutureOr<AccessToken> register
//   (dynamic authData, UserCredential credentials) {
//     // TODO: implement register
//     throw UnimplementedError();
//   }
//
//   @override
//   FutureOr<String> encryptToken(AccessToken token) async {
//     var header = <String, dynamic>{"alg": "HS256", "typ": "JWT"};
//     var payload = token.toMap();
//
//     var base64Payload = base64Url.encode(utf8.encode(json.encode(payload)));
//
//     var base64Header = base64Url.encode(utf8.encode(json.encode(header)));
//
//     ///
//     var cT = "$base64Header.$base64Payload";
//
//     ///
//     var hash = await crypto.calculateSha256Mac(utf8.encode(cT));
//
//     return "$cT.${base64Url.encode(hash)}";
//   }
//
//   @override
//   FutureOr<AccessToken> decryptToken(String token) async {
//     var parts = token.split(".");
//     if (parts.length != 3) {
//       throw UnauthorizedException();
//     }
//
//     var headerText = parts[0];
//     var payloadText = parts[1];
//     var hashBase64 = parts[2];
//
//     var calcHash = await crypto
//         .calculateSha256Mac(utf8.encode("$headerText.$payloadText"));
//
//     var calcHashBase64 = base64Url.encode(calcHash);
//
//     if (calcHashBase64 != hashBase64) {
//       throw UnauthorizedException();
//     }
//
//     return AccessToken.fromMap(
//         json.decode(utf8.decode(base64Url.decode(payloadText))));
//   }
//
//   @override
//   FutureOr<void> verifyToken(AccessToken token) {
//     // TODO: implement verifyToken
//     throw UnimplementedError();
//   }
//
//   @override
//   Component build() {
//     // TODO: implement build
//     throw UnimplementedError();
//   }
// }

// ///
// abstract class RegisterData {
//   ///
//   RegisterData({required this.method, required this.password});
//
//   ///
//   SingInMethod method;
//
//   ///
//   String password;
//
//   ///
//   String? userLoginInput;
// }
