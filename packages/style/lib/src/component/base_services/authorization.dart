/*
 * Copyright (c) 2021. This code was written by Mehmet Yaz.
 * Mehmet Yaz does not accept the problems that may arise due to these codes.
 */

part of '../../style_base.dart';

///
abstract class Authorization extends _BaseService {
  ///
  Authorization();

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

  /*
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

    var secondMacBytes = await context.crypto
        .calculateSha256Mac(utf8.encode(secondPlain));

    // var secondMac = await cAlg.calculateMac(utf8.encode(secondPlain),
    //     secretKey: styleDb.serverConfiguration.tokenKey2);

    var lastMacBase64 = base64Url.encode(secondMacBytes);

    var pHMerged = "$base64Header.$base64Payload";

    var phMergedBase64 = base64Url.encode(utf8.encode(pHMerged));

    return "$phMergedBase64.$lastMacBase64";
  */

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
