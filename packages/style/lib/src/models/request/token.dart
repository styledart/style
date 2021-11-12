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
class EncryptedAccessToken {
  ///
  EncryptedAccessToken(this.token) : assert(token.split(".").length == 3);

  ///
  String token;

  ///
  Future<AccessToken> decrypt(BuildContext context) async {
    var sp = token.split(".");
    if (sp.length != 3) {
      throw Exception();
    }
    var deviceIdBase64 = sp[0];
    var plaintTextBase64 = sp[1];
    var receivedMac = sp[2];

    var plainText = utf8.decode(base64Url.decode(plaintTextBase64));

    var plainSplit = plainText.split(".");

    if (plainSplit.length != 2) {
      throw Exception("Invalid Token Format");
      // throw InvalidTokenFormat(context: context, payload: {
      //   "reason": "plain_text_format_invalid",
      //   "plain_text": plainText
      // });
    }

    var headerBase64Url = plainSplit[0];
    var payloadBase64Url = plainSplit[1];
    var payloadText = utf8.decode(base64Url.decode(payloadBase64Url));

    var payloadMap = json.decode(payloadText) as Map<String, dynamic>;

    if (payloadMap["dm"] == null) {
      throw Exception("Invalid Token Format");
      // throw InvalidTokenFormat(
      //     context: context,
      //     payload: {"reason": "device_id_not_found"});
    }
    var deviceHash = payloadMap["dm"];
    // var cAlg = Hmac.sha256();

    var payloadFirstMacBytes = await context.crypto
        .calculateSha256Mac(base64Url.decode(payloadBase64Url));

    // var payloadFirstMac = await cAlg.calculateMac(
    //     base64Url.decode(payloadBase64Url),
    //     secretKey: styleDb.serverConfiguration.tokenKey1);

    var payloadFirstMacBase64 = base64Url.encode(payloadFirstMacBytes);

    var secondPlain = "$headerBase64Url.$payloadFirstMacBase64";

    var secondMacBytes = await context.crypto
        .calculateSha256Mac(utf8.encode(secondPlain) as Uint8List);

    // var secondMac = await cAlg.calculateMac(utf8.encode(secondPlain),
    //     secretKey: styleDb.serverConfiguration.tokenKey2);

    var lastMacBase64 = base64Url.encode(secondMacBytes);

    if (lastMacBase64 != receivedMac) {
      throw Exception("Token Invalid");
      // throw TokenNotValid(
      //     context: context,
      //     payload: {"reason": "mac_not_valid"});
    }

    //var dAlg = Hmac(Sha1());

    var calcDBytes = await context.crypto.calculateSha1Mac(
        base64Url.decode(utf8.decode(base64Url.decode(deviceIdBase64))));

    // var calcD = await dAlg.calculateMac(
    //     base64Url.decode(utf8.decode(base64Url.decode(deviceIdBase64))),
    //     secretKey: styleDb.serverConfiguration.tokenKey3);

    var deviceCalculatedHash = base64Url.encode(calcDBytes);

    if (deviceCalculatedHash != deviceHash) {
      throw Exception("Token Invalid");
      // throw TokenNotValid(
      //     context: context,
      //     payload: {"reason": "device_id_not_valid"});
    }
    var t = AccessToken.fromMap(payloadMap);

    /// check
    //TODO: Check

    return t;
  }
}

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
