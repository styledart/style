part of '../../style_base.dart';

///
class Gate extends SingleChildCallingComponent {
  ///
  Gate({required Component child, required this.onRequest}) : super(child);

  ///
  final FutureOr<Message> Function(Request request) onRequest;

  @override
  SingleChildCallingBinding createBinding() => SingleChildCallingBinding(this);

  @override
  Calling createCalling(BuildContext context) =>
      GateCalling(context as SingleChildCallingBinding);
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
    try {
      var gateRes = await (binding.component as Gate).onRequest(request);

      if (gateRes is Response) {
        return gateRes;
      } else {
        return binding.child.call(request);
      }
    } on Exception {
      rethrow;
    }
  }
}

///
class AuthFilterGate extends StatelessComponent {
  ///
  const AuthFilterGate(
      {Key? key, required this.child, this.authRequired = true})
      : super(key: key);

  ///
  final Component child;

  /// If false, authorized requests blocked
  final bool authRequired;

  ///
  FutureOr<Message> checkAuth(Request request) {
    //TODO
    if ((authRequired && request.context.accessToken != null) ||
        (!authRequired && request.context.accessToken == null)) {
      return request;
    } else {
      throw Exception(
          authRequired ? "Auth Required" : "Authorized Request not allowed");
    }
  }

  @override
  Component build(BuildContext context) {
    return Gate(child: child, onRequest: checkAuth);
  }
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








