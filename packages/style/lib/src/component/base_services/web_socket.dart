part of '../../style_base.dart';


///
abstract class WebSocketService extends _BaseService {

  ///
  void encrypt();



  @override
  Future<bool> init([bool inInterface = true]) async {
      return true;
  }


}



///
class DefaultSocketServiceHandler extends WebSocketService {

  @override
  void encrypt() {
    // TODO: implement encrypt
  }


}
