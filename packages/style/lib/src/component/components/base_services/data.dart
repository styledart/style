part of '../../../style_base.dart';


///
abstract class DataAccess extends _BaseService {

}



///
class DefaultDataAccessHandler extends DataAccess {
  @override
  Future<void> init()  async {
    print("Data Access Init");
  }

}