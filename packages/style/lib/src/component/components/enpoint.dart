part of '../run.dart';

class EndpointCalling extends Calling {
  EndpointCalling(EndpointCallingBinding endpoint) : super(binding: endpoint);

  @override
  FutureOr<void> onCall(StyleRequest request) {
    // TODO: implement onCall
    throw UnimplementedError();
  }
}

abstract class Endpoint extends CallingComponent {
  Endpoint();

  @override
  CallingBinding createBinding() => EndpointCallingBinding(this);

  @override
  Calling createCalling(BuildContext context) =>
      EndpointCalling(context as EndpointCallingBinding);

  FutureOr<void> onCall(StyleRequest request);
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
    List<Component> ancestorComponents = [];
    CallingBinding? ancestor;
    ancestor = this;
    while (ancestor is! ServiceBinding && ancestor != null) {
      if (ancestor.component is PathSegmentBindingMixin) {
        list.add(((ancestor).component as PathSegmentBindingMixin).segment.name);
      }
      ancestorComponents.add(ancestor.component);
      ancestor = ancestor.ancestorCalling;
    }
    if (list.isEmpty) {
      throw Exception("No Service Found from: \nFrom:$ancestorComponents");
    }

    list.add(owner.httpService.component.httpServiceHandler.address);

    return list.reversed.join("/");
  }

  @override
  TreeVisitor<Binding> visitChildren(TreeVisitor<Binding> visitor) {
    visitor(this);
    return visitor;
  }

  @override
  void _build() {
    print("In calling: $_owner");
    _calling = component.createCalling(this);
  }

  @override
  TreeVisitor<Calling> callingVisitor(TreeVisitor<Calling> visitor) {
    visitor(calling);
    return visitor;
  }
}

class UnknownEndpoint extends Endpoint {
  UnknownEndpoint() : super();

  @override
  FutureOr<void> onCall(StyleRequest request) {
    // TODO: implement onCall
    throw UnimplementedError();
  }
}
