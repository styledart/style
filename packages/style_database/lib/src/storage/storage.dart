part of '../style_database_base.dart';

///
abstract class Storage<T extends Object> {
  ///
  Future<void> create(T object);

  ///
  T? read(String id);

  ///
  Iterator<String> get iterator;
}

class MemoryStorage<T extends Object> extends Storage<T> {
  final Map<String, T> _data = <String, T>{};

  @override
  Future<void> create(T object) async {
    _data[(object as JsonMap)[_idKey] as String] = object;
  }

  @override
  T? read(String id) => _data[id] as T;

  @override
  Iterator<String> get iterator => _data.keys.iterator;
}
