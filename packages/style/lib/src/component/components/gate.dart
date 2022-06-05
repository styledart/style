/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

part of '../../style_base.dart';

///
abstract class GateBase extends SingleChildCallingComponent {
  ///
  GateBase({required super.child, super.key});

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
    var gateRes = await (binding.component as GateBase).onRequest(request);
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
  GateWithChild({required super.child});

  ///
  FutureOr<Message> onRequest(
      Request request, FutureOr<Message> Function(Request) childCalling);

  @override
  SingleChildCallingBinding createBinding() => SingleChildCallingBinding(this);

  @override
  Calling createCalling(BuildContext context) =>
      GateWithChildCalling(context as SingleChildCallingBinding);
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
  AuthFilterGate({super.key, required super.child, this.authRequired = true});

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

class AgentFilterGate extends StatelessComponent {
  ///
  AgentFilterGate(
      {Key? key,
      required this.child,
      this.allowedAgent = const [],
      this.blockedAgents = const []})
      : assert(() {
          for (var blocked in blockedAgents) {
            if (allowedAgent.contains(blocked)) {
              return false;
            }
          }
          return true;
        }(), 'Allowed Methods Contains Blocked Methods'),
        super(key: key);

  ///
  final List<Agent> allowedAgent;

  ///
  final List<Agent> blockedAgents;

  ///
  final Component child;

  ///
  Future<Message> checkAgent(Request request) async {
    if (blockedAgents.contains(request.agent)) {
      //TODO: Detail
      throw Exception('${request.agent} Not Allowed');
    } else if (allowedAgent.isNotEmpty &&
        !allowedAgent.contains(request.agent)) {
      throw Exception('${request.agent} Not Allowed');
    }
    return request;
  }

  @override
  Component build(BuildContext context) =>
      Gate(child: child, onRequest: checkAgent);
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
        }(), 'Allowed Methods Contains Blocked Methods'),
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
      throw Exception('${request.method} Not Allowed');
    } else if (allowedMethods.isNotEmpty &&
        !allowedMethods.contains(request.method)) {
      throw Exception('${request.method} Not Allowed');
    }
    return request;
  }

  @override
  Component build(BuildContext context) =>
      Gate(child: child, onRequest: checkMethods);
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
        }(), 'Allowed Methods Contains Blocked Methods'),
        super(key: key);

  /// use mime type
  final List<Methods> allowedTypes;

  /// Use mime tpye
  final List<Methods> blockedTypes;

  ///
  final Component child;

  ///
  Future<Message> checkMethods(Request request) async {
    if (blockedTypes.contains(request.method!)) {
      //TODO: Detail

      throw MethodNotAllowedException();
    } else if (allowedTypes.isNotEmpty &&
        !allowedTypes.contains(request.method)) {
      throw MethodNotAllowedException();
    }
    return request;
  }

  @override
  Component build(BuildContext context) =>
      Gate(child: child, onRequest: checkMethods);
}

// ///
// class IfModifiedSince extends GateWithChild {
//   ///
//   IfModifiedSince({required Component child, this.responseMaxAge = 0})
//       : super(child: child);
//
//   ///
//   final int responseMaxAge;
//
//   FutureOr<Response> _requestNormal(Request request,
//       FutureOr<Message> Function(Request request) childCalling) async {
//     var rr2 = await childCalling(request);
//     (rr2 as Response).additionalHeaders ??= {};
//     return rr2;
//   }
//
//   @override
//   FutureOr<Response> onRequest(Request request,
//       FutureOr<Message> Function(Request request) childCalling) async {
//     var lastMod = ValidationRequest._getIfModifiedSince(request.headers);
//     if (lastMod != null) {
//       // TODO: Check max age
//       var res = await childCalling(ModifiedSinceRequest(
//           request, lastMod));
//       if (res is ModifiedSinceResponse) {
//         if (res.lastMod.millisecondsSinceEpoch ~/ 1000 >
//             lastMod.millisecondsSinceEpoch ~/ 1000) {
//           return _requestNormal(request, childCalling);
//         } else {
//           return (res)
//             ..statusCode = 304
//             ..body = null;
//         }
//       }
//     }
//     return _requestNormal(request, childCalling);
//   }
// }
