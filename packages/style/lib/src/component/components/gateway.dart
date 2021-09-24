part of '../../style_base.dart';

///
class Gateway extends StatelessComponent {
  ///
  Gateway({this.root, required List<Route> children, Key? key})
      : children = children
            .asMap()
            .map((key, value) => MapEntry(value.segment, value)),
        super(key: key) {
    assert(() {
      var argCount = 0;
      String? _reservedUsed;
      for (var seg in this.children.entries) {
        if (seg.key.name == "*root" || seg.key.name == "*unknown") {
          _reservedUsed = seg.key.name;
        }
        if (seg.key is ArgumentSegment) {
          argCount++;
        }
      }
      return argCount < 2 && _reservedUsed == null;
    }(),
        "Gateway Allow only 1 argument segment\nmaybe cause is *root"
        "and *unknown routes is reserved");
  }

  ///
  final Map<PathSegment, CallingComponent> children;

  ///
  final Component? root;

  @override
  Component build(BuildContext context) {
    return _GatewayCallingComponent(components: children);
  }
}

class _GatewayCallingComponent extends MultiChildCallingComponent {
  _GatewayCallingComponent({required this.components})
      : super(components.values.toList());

  final Map<PathSegment, CallingComponent> components;

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
  void _build() {
    super._build();




  }


}

///
class GatewayCalling extends Calling {
  ///
  GatewayCalling({required CallingBinding binding}) : super(binding: binding) {
    components = {};
    for (var comp in this.binding.children) {
      var seg = (comp as RouteBinding).component.segment;
      components[seg] = comp;
    }
  }

  @override
  MultiChildCallingBinding get binding =>
      super.binding as MultiChildCallingBinding;

  ///
  late final Map<PathSegment, Binding> components;

  @override
  FutureOr<Message> onCall(Request request) {
    return (components[PathSegment(request.currentPath)] ?? binding.unknown)
        .call(request);
  }
}
