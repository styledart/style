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
        throw UnsupportedError("Each Gateway child (Service child) must have"
            "[Route] in the tree."
            "\nwhere: $_errorWhere");
      }

      var seg =
          (_childCalling.result! as RouteCalling).binding.component.segment;

      // if (seg.isRoot || seg.isUnknown) {
      //   if (child.component is PathSegmentCallingComponentMixin) {
      //     throw Exception("(${seg.name}) ,Root and "
      //         "Unknown must not be a new route\n"
      //         "${child.component}\n"
      //         "WHERE: ${child._errorWhere}");
      //   }
      // }

      _callings[seg] = child;
    }

    calling.components = _callings;
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
  late final Map<PathSegment, Binding> components;

  @override
  FutureOr<Message> onCall(Request request) {
    try {
      return (components[PathSegment(request.currentPath)] ?? binding.unknown)
          .findCalling.calling.onCall(request);
    }  on Exception catch(e) {
      print("ON 8 $e");
      rethrow;
    }
  }
}
