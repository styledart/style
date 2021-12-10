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
class AccessToken {
  ///
  AccessToken._(
      {required this.userId,
      required this.additional,
      required this.issuedAtDate,
      required this.issuer,
      required this.tokenID,
      required this.subject,
      this.audience,
      this.expireDate});

  ///
  factory AccessToken.fromMap(Map<String, dynamic> map) {
    return AccessToken._(
        userId: map["uid"],
        additional: map["add"],
        issuedAtDate: DateTime.fromMillisecondsSinceEpoch(map["iat"]),
        issuer: map["iss"],
        tokenID: map["jti"],
        subject: map["sub"],
        audience: map["aud"],
        expireDate: map["exp"] != null
            ? DateTime.fromMillisecondsSinceEpoch(map["exp"])
            : null);
  }

  ///
  static AccessToken create({
    required BuildContext context,
    required String userId,
    Map<String, dynamic>? additional,
    required String subject,
    required String deviceID,
    DateTime? expire,
  }) {
    return AccessToken._(
      userId: userId,
      additional: additional,
      issuedAtDate: DateTime.now(),
      issuer: context.owner.serviceRootName,
      tokenID: getRandomId(12),
      subject: subject,
      expireDate: expire,
    );
  }

  ///
  Map<String, dynamic> toMap() {
    return {
      "uid": userId,
      "iss": issuer,
      "jti": tokenID,
      "sub": subject,
      "iat": issuedAtDate.millisecondsSinceEpoch,
      if (expireDate != null) "exp": expireDate!.millisecondsSinceEpoch,
      if (audience != null) "aud": audience,
      if (additional != null) "add": additional,
      ...?additional
    };
  }

  ///
  Future<String> encrypt(BuildContext context) async {
    var header = <String, dynamic>{"alg": "HS512", "typ": "JWT"};

    var payload = toMap();

    //var cAlg = Hmac.sha256();

    var base64Payload = base64Url.encode(utf8.encode(json.encode(payload)));

    var base64Header = base64Url.encode(utf8.encode(json.encode(header)));

    var payloadFirstMacBytes = await context.crypto
        .calculateSha256Mac(base64Url.decode(base64Payload));

    // var payloadFirstMac = await cAlg.calculateMac(
    //     base64Url.decode(base64Payload),
    //     secretKey: styleDb.serverConfiguration.tokenKey1);

    var payloadFirstMacBase64 = base64Url.encode(payloadFirstMacBytes);

    var secondPlain = "$base64Header.$payloadFirstMacBase64";

    var secondMacBytes =
        await context.crypto.calculateSha256Mac(utf8.encode(secondPlain));

    // var secondMac = await cAlg.calculateMac(utf8.encode(secondPlain),
    //     secretKey: styleDb.serverConfiguration.tokenKey2);

    var lastMacBase64 = base64Url.encode(secondMacBytes);

    var pHMerged = "$base64Header.$base64Payload";

    var phMergedBase64 = base64Url.encode(utf8.encode(pHMerged));

    return "$phMergedBase64.$lastMacBase64";
  }

  /// "jti" Json Web Token Id
  String tokenID;

  /// "uid" User id
  String userId;

  /// "aud"
  String? audience;

  /// "iat" create date
  DateTime issuedAtDate;

  /// "exp" ExpireDate
  DateTime? expireDate;

  /// "iss" issuer
  String issuer;

  /// "sub" Subject
  String subject;

  /// "add"
  Map<String, dynamic>? additional;
}
