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

import 'package:meta/meta.dart';

///
class UserCredential {
  ///
  UserCredential(
      {required this.uid,
        required this.singInMethod,
        required this.createDate,
        required this.mailVerified,
        required this.phoneVerified,
        this.midName,
        this.lastName,
        this.birthDate,
        this.name,
        this.mail,
        this.phone,
        this.userName,
        required this.isNewUser,
        this.authProvider,
        this.additionalData});

  ///
  factory UserCredential.fromReadableJson(Map<String, dynamic> map) {
    return UserCredential(
        uid: map["user_id"],
        singInMethod: SingInMethod.values[map["method"]],
        createDate: map["create_date"],
        mailVerified: map["mail_verified"],
        phoneVerified: map["phone_verified"] ?? false,
        isNewUser: map["is_new_user"],
        authProvider: map["auth_provider"] != null
            ? AuthProvider.fromJson(map["auth_provider"])
            : null,
        birthDate: map["birth_date"] != null
            ? DateTime.fromMillisecondsSinceEpoch(map["birth_date"])
            : null,
        lastName: map["last_name"],
        mail: map["mail"],
        midName: map["mid_name"],
        name: map["name"],
        phone: map["phone"],
        userName: map["user_name"],
        additionalData: map["additional_data"]);
  }

  ///
  factory UserCredential.fromJson(Map<String, dynamic> map) {
    return UserCredential(
        uid: map["uid"],
        singInMethod: SingInMethod.values[map["m"]],
        createDate: map["c_d"],
        mailVerified: map["m_v"],
        phoneVerified: map["p_v"] ?? false,
        isNewUser: map["i_n_u"],
        authProvider:
        map["a_p"] != null ? AuthProvider.fromJson(map["a_p"]) : null,
        birthDate: map["b_d"] != null
            ? DateTime.fromMillisecondsSinceEpoch(map["b_d"])
            : null,
        lastName: map["l_n"],
        mail: map["ma"],
        midName: map["m_n"],
        name: map["n"],
        phone: map["p"],
        userName: map["u_n"],
        additionalData: map["add"]);
  }

  /// User identifier
  String uid;

  /// Not null if set.
  String? mail, phone;

  /// User name information
  String? name, lastName, midName, userName;

  /// User birthDate
  DateTime? birthDate;

  ///
  DateTime createDate;

  /// User singInMethod
  SingInMethod singInMethod;

  ///
  bool mailVerified;

  ///
  bool phoneVerified;

  /// NOT O-AUTH
  @experimental
  AuthProvider? authProvider;

  ///
  bool isNewUser;

  ///
  Map<String, dynamic>? additionalData;
}

///
class AuthProvider {
  ///
  AuthProvider({required this.id, required this.token, this.additionalData});

  ///
  factory AuthProvider.fromJson(Map<String, dynamic> map) {
    return AuthProvider(
        id: map["i"], token: map["t"], additionalData: map["add"]);
  }

  ///
  Map<String, dynamic> toJson() {
    return {
      "i": id,
      "t": token,
      if (additionalData != null) "add": additionalData
    };
  }

  ///
  String id;
  ///
  String token;
  ///
  Map<String, dynamic>? additionalData;
}

///
enum SingInMethod {
  ///
  mailAndPassword,

  ///
  phoneAndCode,

  ///
  phoneAndPassword,

  ///
  userNameAndPassword,

  ///
  mailLink,

  ///
  smsLink,

  ///
  @experimental
  authProvider,
}
