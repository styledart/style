part of '../../style_base.dart';

class EndpointCalling extends Calling {
  EndpointCalling(EndpointCallingBinding endpoint) : super(binding: endpoint);

  @override
  // TODO: implement binding
  EndpointCallingBinding get binding => super.binding as EndpointCallingBinding;

  @override
  FutureOr<Message> onCall(Request request) {

    return binding.component.onCall(request);


    return request.createResponse({
      "path" : "unknown"
    });


    // TODO: implement onCall
    throw UnimplementedError();
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

  FutureOr<Message> onCall(Request request);
}

class EndpointCallingBinding extends CallingBinding {
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
  //       var n = ((ancestor).component as PathSegmentBindingMixin).segment.name;
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

  String get fullPath {
    var list = <String>[];
    var ancestorComponents = <Component>[];
    CallingBinding? ancestor;
    ancestor = this;
    while (ancestor is! ServiceBinding && ancestor != null) {
      if (ancestor.component is PathSegmentBindingMixin) {
        list.add(
            ((ancestor).component as PathSegmentBindingMixin).segment.name);
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
    visitor(calling);
    return visitor;
  }
}

///
class UnknownEndpoint extends Endpoint {
  ///
  UnknownEndpoint() : super();

  @override
  FutureOr<Message> onCall(Request request) {
    return request.createResponse({
      "reason": "route_unknown",
      "route": request.context.pathController.current.name
    });
  }


}
