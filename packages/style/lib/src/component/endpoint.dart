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
      return await binding.component.onCall(request);
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

  @override
  CallingBinding createBinding() {
    return EndpointCallingBinding(this);
  }

  @override
  Calling createCalling(BuildContext context) {
    if (context.component is LastModifiedMixin) {
      return _LastModifiedCalling(context as EndpointCallingBinding);
    } else if (context.component is EtagMixin) {
      return _EtagCalling(context as EndpointCallingBinding);
    }

    return EndpointCalling(context as EndpointCallingBinding);
  }

  ///
  FutureOr<Message> onCall(Request request);
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
    while (ancestor is! ServiceBinding && ancestor != null) {
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
  @override
  EndpointState createState();
}

///
abstract class EndpointState<T extends StatefulEndpoint> extends State<T> {
  ///
  FutureOr<Message> onCall(Request request);

  @override
  Component build(BuildContext context) {
    if (this is LastModifiedStateMixin) {
      return _LastModifiedState(
          onCall, (this as LastModifiedStateMixin).lastModified);
    } else if (this is EtagStateMixin) {
      return _EtagState(onCall, (this as EtagStateMixin).etag);
    }
    return _EndpointState(onCall);
  }
}
