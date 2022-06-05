/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE, Version 3 (the "License");
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

part of '../../style_base.dart';

// /// User auth credentials
// class AuthCredential {}
//
// ///
// class AuthMethod {
//   ///
//   AuthMethod(this.name);
//
//   ///
//   String name;
// }
//
// ///
// class UserCredential {
//
//
//   ///
//   factory UserCredential.createNew(
//       {required String userId, required SingInMethod method}) {
//     return UserCredential(
//         uid: userId,
//         singInMethod: method,
//         createDate: DateTime.now(),
//         mailVerified: false,
//         phoneVerified: false,
//         isNewUser: true);
//   }
//
//   ///
//   UserCredential(
//       {required this.uid,
//       required this.singInMethod,
//       required this.createDate,
//       required this.mailVerified,
//       required this.phoneVerified,
//       this.midName,
//       this.lastName,
//       this.birthDate,
//       this.name,
//       this.mail,
//       this.phone,
//       this.userName,
//       required this.isNewUser,
//       this.authProvider,
//       this.additionalData});
//
//   ///
//   factory UserCredential.fromReadableJson(Map<String, dynamic> map) {
//     return UserCredential(
//         uid: map["user_id"],
//         singInMethod: SingInMethod.values[map["method"]],
//         createDate: map["create_date"],
//         mailVerified: map["mail_verified"],
//         phoneVerified: map["phone_verified"] ?? false,
//         isNewUser: map["is_new_user"],
//         authProvider: map["auth_provider"] != null
//             ? AuthProvider.fromJson(map["auth_provider"])
//             : null,
//         birthDate: map["birth_date"] != null
//             ? DateTime.fromMillisecondsSinceEpoch(map["birth_date"])
//             : null,
//         lastName: map["last_name"],
//         mail: map["mail"],
//         midName: map["mid_name"],
//         name: map["name"],
//         phone: map["phone"],
//         userName: map["user_name"],
//         additionalData: map["additional_data"]);
//   }
//
//   ///
//   factory UserCredential.fromJson(Map<String, dynamic> map) {
//     return UserCredential(
//         uid: map["uid"],
//         singInMethod: SingInMethod.values[map["m"]],
//         createDate: map["c_d"],
//         mailVerified: map["m_v"],
//         phoneVerified: map["p_v"] ?? false,
//         isNewUser: map["i_n_u"],
//         authProvider:
//             map["a_p"] != null ? AuthProvider.fromJson(map["a_p"]) : null,
//         birthDate: map["b_d"] != null
//             ? DateTime.fromMillisecondsSinceEpoch(map["b_d"])
//             : null,
//         lastName: map["l_n"],
//         mail: map["ma"],
//         midName: map["m_n"],
//         name: map["n"],
//         phone: map["p"],
//         userName: map["u_n"],
//         additionalData: map["add"]);
//   }
//
//   ///
//   Map<String, dynamic> toJson() => {
//         "uid": uid,
//         "m": singInMethod.index,
//         "c_d": createDate.millisecondsSinceEpoch,
//         "m_v": mailVerified,
//         "p_v": phoneVerified,
//         "i_n_u": isNewUser,
//         if (authProvider != null) "a_p": authProvider?.toJson(),
//         if (birthDate != null) "b_d": birthDate?.millisecondsSinceEpoch,
//         if (lastName != null) "l_n": lastName,
//         if (mail != null) "ma": mail,
//         if (midName != null) "m_n": midName,
//         if (name != null) "n": name,
//         if (phone != null) "p": phone,
//         if (userName != null) "u_n": userName,
//         if (additionalData != null) "add": additionalData
//       };
//
//   ///
//   Map<String, dynamic> toReadableJson() => {
//         "user_id": uid,
//         "method": singInMethod.index,
//         "create_date": createDate.millisecondsSinceEpoch,
//         "mail_verified": mailVerified,
//         "phone_verified": phoneVerified,
//         "is_new_user": isNewUser,
//         if (authProvider != null) "auth_provider": authProvider?.toJson(),
//         if (birthDate != null) "birth_date":
//         birthDate?.millisecondsSinceEpoch,
//         if (lastName != null) "last_name": lastName,
//         if (mail != null) "mail": mail,
//         if (midName != null) "mid_name": midName,
//         if (name != null) "name": name,
//         if (phone != null) "phone": phone,
//         if (userName != null) "user_name": userName,
//         if (additionalData != null) "additional": additionalData
//       };
//
//   /// User identifier
//   String uid;
//
//   /// Not null if set.
//   String? mail, phone;
//
//   /// User name information
//   String? name, lastName, midName, userName;
//
//   /// User birthDate
//   DateTime? birthDate;
//
//   ///
//   DateTime createDate;
//
//   /// User singInMethod
//   SingInMethod singInMethod;
//
//   ///
//   bool mailVerified;
//
//   ///
//   bool phoneVerified;
//
//   /// NOT O-AUTH
//   @experimental
//   AuthProvider? authProvider;
//
//   ///
//   bool isNewUser;
//
//   ///
//   Map<String, dynamic>? additionalData;
// }
//
// ///
// class AuthProvider {
//   ///
//   AuthProvider({required this.id, required this.token, this.additionalData});
//
//   ///
//   factory AuthProvider.fromJson(Map<String, dynamic> map) {
//     return AuthProvider(
//         id: map["i"], token: map["t"], additionalData: map["add"]);
//   }
//
//   ///
//   Map<String, dynamic> toJson() {
//     return {
//       "i": id,
//       "t": token,
//       if (additionalData != null) "add": additionalData
//     };
//   }
//
//   ///
//   String id;
//
//   ///
//   String token;
//
//   ///
//   Map<String, dynamic>? additionalData;
// }
//
// ///
// enum SingInMethod {
//   ///
//   mailAndPassword,
//
//   ///
//   phoneAndCode,
//
//   ///
//   phoneAndPassword,
//
//   ///
//   userNameAndPassword,
//
//   ///
//   mailLink,
//
//   ///
//   smsLink,
//
//   ///
//   @experimental
//   authProvider,
// }

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
  factory AccessToken.fromMap(Map<String, dynamic> map) => AccessToken._(
        userId: map['uid'] as String,
        additional: map['add'] as Map<String,dynamic>,
        issuedAtDate: DateTime.fromMillisecondsSinceEpoch(map['iat'] as int),
        issuer: map['iss'] as String,
        tokenID: map['jti'] as String,
        subject: map['sub'] as String,
        audience: map['aud'] as String,
        expireDate: map['exp'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['exp'] as int)
            : null);

  ///
  static AccessToken create({
    required BuildContext context,
    required String userId,
    Map<String, dynamic>? additional,
    required String subject,
    required String deviceID,
    required String tokenID,
    DateTime? expire,
  }) => AccessToken._(
      userId: userId,
      additional: additional,
      issuedAtDate: DateTime.now(),
      issuer: context.owner.serviceRootName,
      tokenID: tokenID,
      subject: subject,
      expireDate: expire,
    );

  ///
  Map<String, dynamic> toMap() => {
      'uid': userId,
      'iss': issuer,
      'jti': tokenID,
      'sub': subject,
      'iat': issuedAtDate.millisecondsSinceEpoch,
      if (expireDate != null) 'exp': expireDate!.millisecondsSinceEpoch,
      if (audience != null) 'aud': audience,
      if (additional != null) 'add': additional,
      ...?additional
    };

  ///
  Future<String> encrypt(BuildContext context) async {
    var header = <String, dynamic>{'alg': 'HS512', 'typ': 'JWT'};

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

    var secondPlain = '$base64Header.$payloadFirstMacBase64';

    var secondMacBytes =
        await context.crypto.calculateSha256Mac(utf8.encode(secondPlain));

    // var secondMac = await cAlg.calculateMac(utf8.encode(secondPlain),
    //     secretKey: styleDb.serverConfiguration.tokenKey2);

    var lastMacBase64 = base64Url.encode(secondMacBytes);

    var pHMerged = '$base64Header.$base64Payload';

    var phMergedBase64 = base64Url.encode(utf8.encode(pHMerged));

    return '$phMergedBase64.$lastMacBase64';
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

///
class Nonce {
  ///
  Nonce(this.bytes);

  ///
  factory Nonce.random(int length) {
    var l = <int>[];
    var i = 0;

    while (i < length) {
      l.add(Random().nextInt(255));
      i++;
    }
    return Nonce(Uint8List.fromList(l));
  }

  ///
  Uint8List bytes;
}
