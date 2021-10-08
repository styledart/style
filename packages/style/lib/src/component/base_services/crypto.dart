part of '../../style_base.dart';

///
abstract class CryptoService extends _BaseService {

  ///
  void encrypt();



}

///
 class DefaultCryptoHandler extends CryptoService {

  @override
  void encrypt() {
    // TODO: implement encrypt
  }

  @override
  Future<bool> init([bool inInterface = true]) async {
   return true;
  }

}


