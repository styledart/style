part of '../style_base.dart';

///
class ExceptionHandler {
  ///
  ExceptionHandler(Map<Type, ExceptionEndpointCallingBinding> map)
      : _map = HashMap<Type, ExceptionEndpointCallingBinding>.from(map);

  final HashMap<Type, ExceptionEndpointCallingBinding> _map;

  ///
  ExceptionHandler copyWith([Map<Type, ExceptionEndpointCallingBinding>? map]) {
    var n = ExceptionHandler(_map);
    if (map != null) {
      n._map.addAll(map);
    }
    return n;
  }

  ///
  ExceptionEndpointCallingBinding getBinding(Exception e) {

    print("HANDLER REQUEST:"
        "\n${_map[e.runtimeType]}"
        "\n${_findSuperTypes(e)}"
        "\n${_map[Exception]}");

    return _map[e.runtimeType] ?? _findSuperTypes(e) ?? _map[Exception]!;
  }

  ExceptionEndpointCallingBinding? _findSuperTypes<T extends Exception>(
      Exception e) {
    if (e is StyleException) {
       return _map[e.superType] ?? _map[StyleException];
    }
    return null;
  }
}
