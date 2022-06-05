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

import 'package:meta/meta.dart';

import '../modules.dart';
import 'user_credentials.dart';

///
abstract class AuthModule extends StyleModule {
  ///
  AuthModule({required String key}) : super(key: key);

  ///
  Future<UserCredential> signInWithMailAndPassword(
      String mail, String password);

  @experimental
  ///
  Future<UserCredential> signInWithPhoneAndPassword(
      String phone, String password);

  @experimental
  ///
  Future<UserCredential> signInWithUserNameAndPassword(
      String userName, String password);

  // @experimental
  // Future<UserCredential> signInWithMailLink(String mail, String password);
  //
  // @experimental
  // Future<UserCredential> signInWithSmsLink(String mail, String password);

  @experimental
  ///
  Future<UserCredential> signInWithAuthProvider(String mail, String password);

  @experimental
  ///
  Future<UserCredential> signInWithSmsCode(String phone);

// @experimental
// Future<UserCredential> signInWithMailCode(String mail, String password);
}



///
mixin SmsVerificationSession {
  ///
  SmsVerificationStatus status = SmsVerificationStatus.idle;

  ///
  String get phone;

  ///
  Duration get timeout;

  ///
  void reSendCodeSms() {
    _startRemaining();
  }

  ///
  Future<SmsVerificationInfo> verifyCode(String code) {
    throw 0;
  }

  late final StreamController<Duration?> _remainingController =
      StreamController<Duration>.broadcast();

  ///
  Stream<Duration?> get remainingSeconds => _remainingController.stream;

  ///
  DateTime? expire;

  late Timer _timer;

  ///
  void _startRemaining() {
    _timer = Timer(timeout, () {
      if (expire == null) return;
      var dif = expire!.difference(DateTime.now());
      if (dif.isNegative) {
        _timer.cancel();
      }
      _remainingController.add(dif);
    });
  }

  ///
  void endSession() {
    _remainingController.close();
    if (_timer.isActive) _timer.cancel();
  }
}

///
class SmsVerificationInfo {
  ///
  SmsVerificationInfo({required this.id, required this.expire});

  ///
  String id;

  ///
  DateTime expire;
}

///
enum SmsVerificationStatus {
  ///
  idle,
  ///
  codeSent,
  ///
  verificationWaiting,
  ///
  verified,
  ///
  notVerified,
  ///
  timeout,
}
