part of '../style_base.dart';

///
class ExceptionHandler extends MapBase<Type, ExceptionEndpointCallingBinding> {
  ///
  ExceptionHandler(Map<Type, ExceptionEndpointCallingBinding> map)
      : _map = HashMap<Type, ExceptionEndpointCallingBinding>.from(map);

  final HashMap<Type, ExceptionEndpointCallingBinding> _map;

  ///
  Binding get unknown => this[NotFoundException];

  ///
  ServiceUnavailable get unavailableService =>
      this[ServiceUnavailable] as ServiceUnavailable;

  ///
  ExceptionHandler copyWith([Map<Type, ExceptionEndpointCallingBinding>? map]) {
    var n = ExceptionHandler(_map);
    if (map != null) {
      n._map.addAll(map);
    }
    return n;
  }

  @override
  ExceptionEndpointCallingBinding operator [](covariant Type key) {
    return _map[key] ?? _map[Exception]!;
  }

  @override
  void operator []=(Type key, ExceptionEndpointCallingBinding value) {
    throw UnsupportedError("Not supported. Use ExceptionWrapper");
  }

  @override
  void clear() {
    _map.clear();
  }

  @override
  Iterable<Type> get keys => _map.keys;

  @override
  ExceptionEndpointCallingBinding? remove(covariant Type key) {
    return _map.remove(key);
  }
}
