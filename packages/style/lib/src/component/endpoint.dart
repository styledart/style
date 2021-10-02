part of '../style_base.dart';



///
class EndpointCalling extends Calling {
  ///
  EndpointCalling(EndpointCallingBinding endpoint) : super(endpoint);

  @override
  // TODO: implement binding
  EndpointCallingBinding get binding => super.binding as EndpointCallingBinding;

  @override
  FutureOr<Message> onCall(Request request) {
    return binding.component.onCall(request);
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
  CallingBinding createBinding() => EndpointCallingBinding(this);

  @override
  Calling createCalling(BuildContext context) =>
      EndpointCalling(context as EndpointCallingBinding);

  ///
  FutureOr<Message> onCall(Request request);
}

///
class EndpointCallingBinding extends CallingBinding {
  ///
  EndpointCallingBinding(CallingComponent component) : super(component);

  @override
  Endpoint get component => super.component as Endpoint;

  // String get lastPath {
  //
  //   String? path;
  //
  //   List<Component> ancestorComponents = [];
  //   CallingBinding? ancestor;
  //   ancestor = this;
  //
  //   while (ancestor is! ServiceBinding && ancestor != null) {
  //     if (ancestor.component is PathSegmentBindingMixin) {
  //       var n = ((ancestor).component as PathSegmentBindingMixin)
  //                  .segment.name;
  //       if (!(n == "*root" || n == "*unknown")) {
  //         path = n;
  //         break;
  //       }
  //     }
  //     ancestorComponents.add(ancestor.component);
  //     ancestor = ancestor.ancestorCalling;
  //   }
  //
  // }

  ///
  String get fullPath {
    var list = <String>[];
    var ancestorComponents = <Component>[];
    CallingBinding? ancestor;
    ancestor = this;
    while (ancestor is! ServiceBinding && ancestor != null) {
      if (ancestor.component is PathSegmentMixin) {
        var seg = ((ancestor).component as PathSegmentMixin).segment;
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
    component._context = this;
    _calling = component.createCalling(this);
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
    return _EndpointState(onCall);
  }
}

class _EndpointState extends Endpoint {
  _EndpointState(this.call);

  final FutureOr<Message> Function(Request request) call;

  @override
  FutureOr<Message> onCall(Request request) {
    return call(request);
  }
}
