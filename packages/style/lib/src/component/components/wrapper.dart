part of '../../style_base.dart';

///
class ExceptionWrapper<T extends Exception> extends StatelessComponent {
  ///
  factory ExceptionWrapper(
      {required Component child,
      required ExceptionEndpoint<T> exceptionEndpoint,
      Key? key}) {
    return ExceptionWrapper.fromMap(child: child, map: {T: exceptionEndpoint});
  }

  ///
  ExceptionWrapper.fromMap(
      {required this.child,
      required Map<Type, ExceptionEndpoint> map,
      Key? key})
      : _map = map,
        super(key: key);

  ///
  final Component child;

  final Map<Type, ExceptionEndpoint> _map;

  @override
  Component build(BuildContext context) {
    return child;
  }

  @override
  StatelessBinding createBinding() {
    return _ExceptionWrapperBinding(this);
  }
}

class _ExceptionWrapperBinding extends StatelessBinding {
  _ExceptionWrapperBinding(ExceptionWrapper component) : super(component);

  @override
  void _build() {
    if (_exceptionHandler == null) {
      component._map.addAll({
        InternalServerError: DefaultExceptionEndpoint<InternalServerError>()
      });
    }
    var _bindings = <Type, ExceptionEndpointCallingBinding>{};
    for (var w in component._map.entries) {
      _bindings[w.key] = w.value.createBinding();
    }
    _exceptionHandler ??= ExceptionHandler({});
    exceptionHandler._map.addAll(_bindings);
    var p = _parent;
    while (p != null && p._exceptionHandler == null) {
      p._exceptionHandler = _exceptionHandler;
      p = p._parent;
    }
    for (var _b in _bindings.values) {
      _b.attachToParent(this);
      _b._build();
    }
    for (var _b in _bindings.values) {
      var r = _b.visitChildren(TreeVisitor((visitor) {
        if (visitor.currentValue.component
                is PathSegmentCallingComponentMixin ||
            visitor.currentValue is GatewayBinding) {
          visitor.stop();
        }
      }));
      if (r.result != null) {
        throw Exception("[exception] tree must ends with Endpoint"
            "\nAnd must not have a new route\n"
            "Ensure exception/exception's any child not [Route, RouteTo, GateWay]\n"
            "WHERE: $_errorWhere");
      }
    }

    super._build();
  }

  @override
  ExceptionWrapper get component => super.component as ExceptionWrapper;
}

///
class IfMatchWrapper extends SingleChildCallingComponent {
  ///
  IfMatchWrapper(Component child) : super(child);

  @override
  SingleChildCallingBinding createBinding() => SingleChildCallingBinding(this);

  @override
  Calling createCalling(covariant SingleChildCallingBinding context) =>
      _IfMatchCalling(context);
}

class _IfMatchCalling extends Calling {
  _IfMatchCalling(SingleChildCallingBinding binding) : super(binding);

  @override
  FutureOr<Message> onCall(Request request) {
    // TODO: implement onCall
    throw UnimplementedError();
  }
}
