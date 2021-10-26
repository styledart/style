part of '../../style_base.dart';

///
class Gateway extends MultiChildCallingComponent {
  ///
  Gateway({required List<Component> children}) : super(children);

  @override
  GatewayBinding createBinding() => GatewayBinding(this);

  @override
  Calling createCalling(BuildContext context) =>
      GatewayCalling(binding: context as CallingBinding);
}

///
class GatewayBinding extends MultiChildCallingBinding {
  ///
  GatewayBinding(MultiChildCallingComponent component) : super(component);

  @override
  GatewayCalling get calling => super.calling as GatewayCalling;

  @override
  void attachToParent(Binding parent) {
    super.attachToParent(parent);

    var _route = findAncestorBindingOfType<RouteBinding>();
    var _service = findAncestorBindingOfType<ServiceBinding>();

    if (_route == null && _service == null) {
      throw UnsupportedError("Each Gateway must ancestor of Service or Route"
          "\nwhere:$_errorWhere");
    }
  }

  @override
  void _build() {
    super._build();

    var _callings = <PathSegment, Binding>{};
    PathSegment? arg ;
    for (var child in children) {
      var _childCalling = child.visitCallingChildren(TreeVisitor((visitor) {
        if (visitor.currentValue is GatewayCalling) {
          visitor.stop();
          return;
        }

        if (visitor.currentValue is RouteCalling) {
          visitor.stop();
        }
      }));

      if (_childCalling.result is GatewayCalling) {
        throw UnsupportedError("There must be a route between the two gateways."
            "\nwhere: $_errorWhere");
      }

      if (_childCalling.result == null) {
        throw UnsupportedError("Each Gateway child (or Service child) must have"
            "[Route] in the tree."
            "\nwhere: $_errorWhere");
      }

      var seg =
          (_childCalling.result! as RouteCalling).binding.component.segment;

      if (seg.isArgument) {
        if (arg != null) {
          throw Exception(
              "Gateways allow only once argument segment. \nbut found $arg and"
                  " $seg\nWHERE: $_errorWhere");
        } else {
          arg = seg;
        }
      }
      _callings[seg] = child;
    }

    calling.childrenBinding = _callings;
  }
}

///
class GatewayCalling extends Calling {
  ///
  GatewayCalling({required CallingBinding binding}) : super(binding);

  @override
  MultiChildCallingBinding get binding =>
      super.binding as MultiChildCallingBinding;

  ///
  late final Map<PathSegment, Binding> childrenBinding;

  @override
  FutureOr<Message> onCall(Request request) {
    if (childrenBinding[PathSegment(request.currentPath)] != null) {
      return childrenBinding[PathSegment(request.currentPath)]!
          .findCalling
          .calling(request);
    } else {
      throw NotFoundException(request.currentPath);
    }
  }
}
