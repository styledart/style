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

part of '../style_base.dart';

///
class EndpointCalling extends Calling {
  ///
  EndpointCalling(EndpointCallingBinding endpoint) : super(endpoint);

  @override
  EndpointCallingBinding get binding => super.binding as EndpointCallingBinding;

  @override
  FutureOr<Message> onCall(Request request) async {
    try {
      var val = await binding.component.onCall(request);
      if (val is Future) {
        var r = await val;
        if (r is Message) {
          return r;
        } else {
          return request.response(r);
        }
      }
      if (val is Message) {
        return val;
      } else {
        return request.response(val);
      }
    } on Exception {
      rethrow;
    }
  }
}

///
class ExceptionEndpointCalling<T extends Exception> extends EndpointCalling {
  ///
  ExceptionEndpointCalling(ExceptionEndpointCallingBinding<T> endpoint)
      : super(endpoint);

  @override
  ExceptionEndpointCallingBinding get binding =>
      super.binding as ExceptionEndpointCallingBinding;

  @override
  FutureOr<Message> onCall(Request request,
      [T? exception, StackTrace? stackTrace]) {
    return binding.component.onCall(request, exception, stackTrace);
  }
}

///
abstract class Endpoint extends CallingComponent {
  ///
  Endpoint({Key? key}) : super(key: key);

  ///
  late final BuildContext? _context;

  ///
  BuildContext get context => _context!;

  ///
  FutureOr<ReadDbResult> Function(Read event) get dbRead =>
      DataAccess.of(context).read;

  @override
  CallingBinding createBinding() {
    return EndpointCallingBinding(this);
  }

  @override
  Calling createCalling(BuildContext context) {
    return EndpointCalling(context as EndpointCallingBinding);
  }

  ///
  FutureOr<dynamic> onCall(Request request);
}

///
class ExceptionEndpointCallingBinding<T extends Exception>
    extends EndpointCallingBinding {
  ///
  ExceptionEndpointCallingBinding(ExceptionEndpoint<T> component)
      : super(component);

  @override
  ExceptionEndpoint<T> get component => super.component as ExceptionEndpoint<T>;

  @override
  ExceptionEndpointCalling<T> get calling =>
      super.calling as ExceptionEndpointCalling<T>;
}

///
class EndpointCallingBinding extends CallingBinding {
  ///
  EndpointCallingBinding(CallingComponent component) : super(component);

  @override
  Endpoint get component => super.component as Endpoint;

  ///
  String get fullPath {
    var list = <String>[];
    var ancestorComponents = <Component>[];
    CallingBinding? ancestor;
    ancestor = this;
    while (ancestor is! ServerBinding && ancestor != null) {
      if (ancestor.component is PathSegmentCallingComponentMixin) {
        var seg =
            ((ancestor).component as PathSegmentCallingComponentMixin).segment;
        list.add(seg is ArgumentSegment ? "{${seg.name}}" : seg.name);
      }
      ancestorComponents.add(ancestor.component);
      ancestor = ancestor.ancestorCalling;
    }
    if (list.isEmpty) {
      throw Exception("No Service Found from: \nFrom:$ancestorComponents");
    }
    list.add(owner.httpService.address);
    return list.reversed.join("/");
  }

  @override
  TreeVisitor<Binding> visitChildren(TreeVisitor<Binding> visitor) {
    if (visitor._stopped) return visitor;
    visitor(this);
    return visitor;
  }

  @override
  void _build() {
    try {
      component._context = this;
      _calling = component.createCalling(this);
    } on Exception {
      rethrow;
    }
  }

  @override
  TreeVisitor<Calling> callingVisitor(TreeVisitor<Calling> visitor) {
    if (visitor._stopped) return visitor;
    visitor(calling);
    return visitor;
  }
}

///
abstract class StatefulEndpoint extends StatefulComponent {
  ///
  StatefulEndpoint({GlobalKey? key}) : super(key: key);

  @override
  EndpointState createState();
}

///
abstract class EndpointState<T extends StatefulEndpoint> extends State<T> {
  ///
  FutureOr<Object> onCall(Request request);

  ///
  DataAccess get db => DataAccess.of(context);

  @override
  Component build(BuildContext context) {
    return _EndpointState(onCall);
  }
}

///
abstract class LastModifiedEndpointState<T extends StatefulEndpoint>
    extends EndpointState<T> {
  ///
  FutureOr<ResponseWithLastModified> onRequest(
      ValidationRequest<DateTime> request);

  FutureOr<ResponseWithLastModified> onCall(
          covariant ValidationRequest<DateTime> request) =>
      onRequest(request);

  @override
  Component build(BuildContext context) {
    return _LastModifiedEndpointState(onRequest);
  }
}

///
abstract class EtagEndpointState<T extends StatefulEndpoint>
    extends EndpointState<T> {
  // ///
  FutureOr<ResponseWithEtag> onCall(
          covariant ValidationRequest<String> request) =>
      onRequest(request);

  ///
  FutureOr<ResponseWithEtag> onRequest(ValidationRequest<String> request);

  @override
  Component build(BuildContext context) {
    return _EtagEndpointState(onRequest);
  }
}

class _EndpointState extends Endpoint {
  _EndpointState(this.call);

  final FutureOr<Object> Function(Request request) call;

  @override
  FutureOr<Object> onCall(Request request) {
    return call(request);
  }
}

class _LastModifiedEndpointState extends LastModifiedEndpoint {
  _LastModifiedEndpointState(this.call);

  final FutureOr<ResponseWithCacheControl<DateTime>> Function(
      ValidationRequest<DateTime> request) call;

  @override
  FutureOr<ResponseWithCacheControl<DateTime>> onRequest(
      ValidationRequest<DateTime> request) {
    return call(request);
  }
}

///
class _EtagEndpointState extends EtagEndpoint {
  _EtagEndpointState(this.call);

  final FutureOr<ResponseWithCacheControl<String>> Function(
      ValidationRequest<String> request) call;

  @override
  FutureOr<ResponseWithCacheControl<String>> onRequest(
      ValidationRequest<String> request) {
    return call(request);
  }
}

///
abstract class LastModifiedEndpoint extends Endpoint {
  ///
  LastModifiedEndpoint();

  ///
  FutureOr<ResponseWithCacheControl<DateTime>> onRequest(
      ValidationRequest<DateTime> request);

  @override
  FutureOr onCall(Request request) {

    if (request is! ValidationRequest<DateTime>) {

      var _parent = (context as Binding).ancestorCalling;
      while (_parent != null){
        print("$_parent");
        _parent = _parent.ancestorCalling;
      }
      print("Req: ${request.path.calledPath}");
    }
    return onRequest(request as ValidationRequest<DateTime>);
  }
}

///
abstract class EtagEndpoint extends Endpoint {
  ///
  EtagEndpoint();

  ///
  FutureOr<ResponseWithCacheControl<String>> onRequest(
      ValidationRequest<String> request);

  @override
  FutureOr onCall(Request request) =>
      onRequest(request as ValidationRequest<String>);
}
