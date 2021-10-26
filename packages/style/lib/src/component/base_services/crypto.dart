part of '../../style_base.dart';

///
abstract class Crypto extends _BaseService {
  ///
  FutureOr<String> passwordHash(String clearText);

  ///
  FutureOr<String> encrypt(
      String plain, Uint8List clientNonce, Uint8List serverNonce);

  ///
  FutureOr<String> decrypt(
      String cipher, Uint8List clientNonce, Uint8List serverNonce);

  ///
  FutureOr<List<int>> calculateSha256Mac(List<int> plain);

  ///
  FutureOr<List<int>> calculateSha1Mac(List<int> plain);
}

///
class DefaultCryptoHandler extends Crypto {
  @override
  FutureOr<bool> init([bool inInterface = true]) async {
    return true;
  }

  @override
  FutureOr<List<int>> calculateSha1Mac(List<int> plain) {
    // TODO: implement calculateSha1Mac
    throw UnimplementedError();
  }

  @override
  FutureOr<List<int>> calculateSha256Mac(List<int> plain) {
    // TODO: implement calculateSha256Mac
    throw UnimplementedError();
  }


  ///
  FutureOr<List<int>> calculateSha256MacAlternative(List<int> plain) {
    // TODO: implement calculateSha256MacAlternative
    throw UnimplementedError();
  }

  @override
  FutureOr<String> passwordHash(String clearText) {
    // TODO: implement passwordHash
    throw UnimplementedError();
  }

  @override
  FutureOr<String> decrypt(
      String cipher, Uint8List clientNonce, Uint8List serverNonce) {
    // TODO: implement decrypt
    throw UnimplementedError();
  }

  @override
  FutureOr<String> encrypt(
      String plain, Uint8List clientNonce, Uint8List serverNonce) {
    // TODO: implement encrypt
    throw UnimplementedError();
  }
}
