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
    super._build();
  }

  @override
  UnknownWrapper get component => super.component as UnknownWrapper;
}

///
class Gate extends SingleChildCallingComponent {
  ///
  Gate({required Component child, required this.onRequest}) : super(child);

  ///
  final FutureOr<Request> Function(Request request) onRequest;

  @override
  SingleChildCallingBinding createBinding() => SingleChildCallingBinding(this);

  @override
  Calling createCalling(BuildContext context) =>
      GateCalling(context as SingleChildCallingBinding);
}

///
class GateCalling extends Calling {
  ///
  GateCalling(SingleChildCallingBinding binding) : super(binding: binding);

  @override
  // TODO: implement binding
  SingleChildCallingBinding get binding =>
      super.binding as SingleChildCallingBinding;

  @override
  FutureOr<Message> onCall(Request request) {
    // TODO: implement onCall
    throw UnimplementedError();
  }
}

///
class SimpleEndpoint extends Endpoint {
  ///
  SimpleEndpoint(this.onRequest);

  ///
  final FutureOr<Message> Function(Request request)
      onRequest;

  @override
  FutureOr<Message> onCall(Request request) =>
      onRequest(request);
}
