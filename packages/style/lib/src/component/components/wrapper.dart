part of '../../style_base.dart';

/// Unknown Wrapper set sub-context default [unknown]
///
class UnknownWrapper extends StatelessComponent {
  /// Unknown must one of endpoint in sub-tree
  UnknownWrapper({Key? key, required this.unknown, required this.child})
      : super(key: key);

  ///
  final Component child, unknown;

  @override
  Component build(BuildContext context) {
    return child;
  }

  @override
  StatelessBinding createBinding() {
    return _UnknownWrapperBinding(this);
  }
}

class _UnknownWrapperBinding extends StatelessBinding {
  _UnknownWrapperBinding(UnknownWrapper component) : super(component);

  @override
  void _build() {
    _unknown = component.unknown.createBinding();
    _unknown!.attachToParent(this);
    _unknown!._build();
    var r = _unknown!.visitChildren(TreeVisitor((visitor) {
      if (visitor.currentValue.component is PathSegmentCallingComponentMixin ||
          visitor.currentValue is GatewayBinding) {
        visitor.stop();
      }
    }));
    if (r.result != null) {
      throw Exception("[unknown] tree must ends with Endpoint"
          "\nAnd must not have a new route\n"
          "Ensure unknown/unknown's any child not [Route, RouteTo, GateWay]\n"
          "WHERE: $_errorWhere");
    }
    super._build();
  }

  @override
  UnknownWrapper get component => super.component as UnknownWrapper;
}

/// Unknown Wrapper set sub-context default [unknown]
///
class ErrorWrapper extends StatelessComponent {
  /// Unknown must one of endpoint in sub-tree
  ErrorWrapper({Key? key, required this.error, required this.child})
      : super(key: key);

  ///
  final Component child, error;

  @override
  Component build(BuildContext context) {
    return child;
  }

  @override
  StatelessBinding createBinding() {
    return _ErrorWrapperBinding(this);
  }
}

class _ErrorWrapperBinding extends StatelessBinding {
  _ErrorWrapperBinding(ErrorWrapper component) : super(component);

  @override
  void _build() {
    _error = component.error.createBinding();
    _error!.attachToParent(this);
    _error!._build();
    var haveRoute = false;
    var e = _error!.visitChildren(TreeVisitor((visitor) {
      if (visitor.currentValue.component is PathSegmentCallingComponentMixin ||
          visitor.currentValue is GatewayBinding) {
        haveRoute = true;
        visitor.stop();
      } else if (visitor.currentValue.component is ErrorEndpoint) {
        visitor.stop();
      }
    }));
    if (haveRoute || e.result == null) {
      throw Exception("[error] tree must ends with ErrorEndpoint"
          "\nAnd must not have a new route\n"
          "Ensure error/error's any child not [Route, RouteTo, GateWay]");
    }
    super._build();
  }

  @override
  ErrorWrapper get component => super.component as ErrorWrapper;
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
