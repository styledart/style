part of '../../style_base.dart';

///
abstract class DataAccess extends _BaseService {
  ///
  Future<Map<String, dynamic>> read(Query query);

  ///
  Future<Map<String, dynamic>> readList(Query query);

  ///
  Future<Map<String, dynamic>> delete(Query query);

  ///
  Future<Map<String, dynamic>> update(Query query, Map<String, dynamic> update);

  ///
  Future<Map<String, dynamic>> create(
      Query query, Map<String, dynamic> document);

  ///
  Future<StreamController<Map<String, dynamic>>> listen(
      Query query, Map<String, dynamic> document) {
    throw 0;
  }
}

///
class SimpleCacheDataAccess extends DataAccess {
  ///
  final Map<String, Map<String, Map<String, dynamic>>> data = {};

  @override
  Future<bool> init([bool inInterface = true]) async {
    return true;
  }

  @override
  Future<Map<String, dynamic>> create(
      Query query, Map<String, dynamic> document) {
    //
    // data[query.collection] ??= <String, Map<String, dynamic>>{};
    // data[query.collection]![query.selectorBuilder!] = document;
    return Future.value(<String, dynamic>{"ok": 1});
  }

  @override
  Future<Map<String, dynamic>> delete(Query query) {
    // data[query.collection]?.remove(query.selectorBuilder);
    return Future.value(<String, dynamic>{"ok": 1});
  }

  @override
  Future<Map<String, dynamic>> read(Query query) async {
    // if (query.selectorBuilder == null) {
    //   return data[query.collection] ?? {"ok": 0};
    // }
    return /*data[query.collection]?[query.selectorBuilder] ??*/ {"ok": 0};
  }

  @override
  Future<Map<String, dynamic>> update(
      Query query, Map<String, dynamic> update) {
    // data[query.collection] ??= <String, Map<String, dynamic>>{};
    // data[query.collection]![query.selectorBuilder!] ??= <String, dynamic>{};
    // data[query.collection]![query.selectorBuilder]!.addAll(update);
    return Future.value(<String, dynamic>{"ok": 1});
  }

  @override
  Future<Map<String, dynamic>> readList(Query query) {
    // TODO: implement readList
    throw UnimplementedError();
  }
}
