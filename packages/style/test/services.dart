/*
 * Copyright (c) 2021. This code was written by Mehmet Yaz.
 * Mehmet Yaz does not accept the problems that may arise due to these codes.
 */

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';
import 'package:style_dart/src/style_base.dart';

class MyServer extends StatelessComponent {
  const MyServer({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) {
    return Server(children: []);
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
    //print("Cipher: $cipher");
    var split = cipher.split(".");
    if (split.length != 2) {
      throw Exception("Invalid cipher text");
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
    var en =
        "${base64Url.encode(scBox.mac.bytes)}"
        ".${base64Url.encode(scBox.cipherText)}";
    //print("ENC1: $en");
    return en;
  }

  Future<String> encrypt2ndStage(String plain, Uint8List serverNonce) async {
    var scBox = await algorithm.encrypt(utf8.encode(plain),
        secretKey: secretKey1, nonce: serverNonce);
    var en =
        "${base64Url.encode(scBox.mac.bytes)}"
        ".${base64Url.encode(scBox.cipherText)}";
    //print("ENC2: $en");
    return en;
  }

  Future<String> decrypt2ndStage(String cipher, Uint8List serverNonce) async {
    //print("Cipher2: $cipher");
    var split = cipher.split(".");
    if (split.length != 2) {
      throw Exception("Invalid cipher text");
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
      String cipher, Uint8List clientNonce, Uint8List serverNonce) async {
    return decrypt2ndStage(
        await decrypt1stStage(cipher, clientNonce), serverNonce);
  }

  @override
  FutureOr<String> encrypt(
      String plain, Uint8List clientNonce, Uint8List serverNonce) async {
    return encrypt2ndStage(
        await encrypt1stStage(plain, clientNonce), clientNonce);
  }

  @override
  FutureOr<bool> init([bool inInterface = true]) {
    return true;
  }

  @override
  FutureOr<String> passwordHash(String clearText) {
    // TODO: implement passwordHash
    throw UnimplementedError();
  }
}
