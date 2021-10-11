part of '../../style_base.dart';

///
abstract class GateBase extends SingleChildCallingComponent {
  ///
  GateBase({required Component child, Key? key}) : super(child);

  ///
  FutureOr<Message> onRequest(Request request);

  @override
  SingleChildCallingBinding createBinding() => SingleChildCallingBinding(this);

  @override
  Calling createCalling(BuildContext context) =>
      GateCalling(context as SingleChildCallingBinding);
}

///
class Gate extends GateBase {
  ///
  Gate(
      {required Component child,
      required FutureOr<Message> Function(Request request) onRequest})
      : _onRequest = onRequest,
        super(child: child);

  ///
  final FutureOr<Message> Function(Request request) _onRequest;

  @override
  FutureOr<Message> onRequest(Request request) => _onRequest(request);
}

///
class GateCalling extends Calling {
  ///
  GateCalling(SingleChildCallingBinding binding) : super(binding);

  @override
  SingleChildCallingBinding get binding =>
      super.binding as SingleChildCallingBinding;

  @override
  FutureOr<Message> onCall(Request request) async {
    var gateRes = await (binding.component as Gate).onRequest(request);
    if (gateRes is Response) {
      return gateRes;
    } else {
      return binding.child.findCalling.calling(request);
    }
  }
}

///
abstract class GateWithChild extends SingleChildCallingComponent {
  ///
  GateWithChild({required Component child}) : super(child);

  ///
  FutureOr<Response> onRequest(
      Request request, FutureOr<Message> Function(Request) childCalling);

  @override
  SingleChildCallingBinding createBinding() => SingleChildCallingBinding(this);

  @override
  Calling createCalling(BuildContext context) =>
      GateCalling(context as SingleChildCallingBinding);
}

///
class GateWithChildCalling extends Calling {
  ///
  GateWithChildCalling(SingleChildCallingBinding binding) : super(binding);

  @override
  SingleChildCallingBinding get binding =>
      super.binding as SingleChildCallingBinding;

  @override
  FutureOr<Message> onCall(Request request) async {
    var gateRes = await (binding.component as GateWithChild)
        .onRequest(request, binding.child.findCalling.calling);

    return gateRes;
  }
}

///
class AuthFilterGate extends GateBase {
  ///
  AuthFilterGate({Key? key, required this.child, this.authRequired = true})
      : super(key: key, child: child);

  ///
  final Component child;

  /// If false, authorized requests blocked
  final bool authRequired;

  ///
  FutureOr<Message> checkAuth(Request request) {
    if ((authRequired && request.context.accessToken != null) ||
        (!authRequired && request.context.accessToken == null)) {
      return request;
    } else {
      throw UnauthorizedException();
    }
  }

  @override
  FutureOr<Message> onRequest(Request request) => checkAuth(request);
}

///
class MethodFilterGate extends StatelessComponent {
  ///
  MethodFilterGate(
      {Key? key,
      required this.child,
      this.allowedMethods = const [],
      this.blockedMethods = const []})
      : assert(() {
          for (var blocked in blockedMethods) {
            if (allowedMethods.contains(blocked)) {
              return false;
            }
          }
          return true;
        }(), "Allowed Methods Contains Blocked Methods"),
        super(key: key);

  ///
  final List<Methods> allowedMethods;

  ///
  final List<Methods> blockedMethods;

  ///
  final Component child;

  ///
  Future<Message> checkMethods(Request request) async {
    if (blockedMethods.contains(request.method!)) {
      //TODO: Detail
      throw Exception("${request.method} Not Allowed");
    } else if (allowedMethods.isNotEmpty &&
        !allowedMethods.contains(request.method)) {
      throw Exception("${request.method} Not Allowed");
    }
    return request;
  }

  @override
  Component build(BuildContext context) {
    return Gate(child: child, onRequest: checkMethods);
  }
}

///
class ContentTypeFilterGate extends StatelessComponent {
  ///
  ContentTypeFilterGate(
      {Key? key,
      required this.child,
      this.allowedTypes = const [],
      this.blockedTypes = const []})
      : assert(() {
          for (var blocked in blockedTypes) {
            if (allowedTypes.contains(blocked)) {
              return false;
            }
          }
          return true;
        }(), "Allowed Methods Contains Blocked Methods"),
        super(key: key);

  /// use mime type
  final List<String> allowedTypes;

  /// Use mime tpye
  final List<String> blockedTypes;

  ///
  final Component child;

  ///
  Future<Message> checkMethods(Request request) async {
    if (blockedTypes.contains(request.method!)) {
      //TODO: Detail
      throw Exception("${request.method} Not Allowed");
    } else if (allowedTypes.isNotEmpty &&
        !allowedTypes.contains(request.method)) {
      throw Exception("${request.method} Not Allowed");
    }
    return request;
  }

  @override
  Component build(BuildContext context) {
    return Gate(child: child, onRequest: checkMethods);
  }
}

///
class CacheControl extends GateBase {
  ///
  CacheControl({required Component child, Key? key})
      : super(child: child, key: key);

  @override
  FutureOr<Message> onRequest(Request request) {
    // TODO: implement onRequest
    throw UnimplementedError();
  }
}

///
class IfModifiedSince extends GateWithChild {
  ///
  IfModifiedSince({required Component child}) : super(child: child);

  @override
  FutureOr<Response> onRequest(Request request,
      FutureOr<Message> Function(Request request) childCalling) {
    // TODO: implement onRequest
    throw UnimplementedError();
  }
}
