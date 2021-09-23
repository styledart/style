part of '../../style_base.dart';

///
class Gateway extends StatelessComponent {
  ///
  Gateway({this.root, required List<PathRouter> children, Key? key})
      : children = children.asMap().map((key, value) =>
            MapEntry(value.segment, value)),
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

  final Map<PathSegment, CallingComponent> children;

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
  Calling createCalling(BuildContext context) =>
      GatewayCalling(binding: context as CallingBinding);
}

///
class GatewayCalling extends Calling {
  ///
  GatewayCalling({required CallingBinding binding}) : super(binding: binding) {
    components = {};
    for (var comp in this.binding.children) {
      var seg = (comp as PathRouterCallingBinding).component.segment;
      components[seg] = comp;
    }

    // components = this.binding.children.asMap().map((key, value) =>
    //     MapEntry((value as PathRouterCallingBinding).component.segment, value));
  }

  @override
  MultiChildCallingBinding get binding =>
      super.binding as MultiChildCallingBinding;

  ///
  late final Map<PathSegment, Binding> components;

  @override
  FutureOr<Message> onCall(Request request) {

    print(request.path.notProcessedValues);
    print(components.keys);
    var _p = request.path.resolveFor(components.keys);

    print("Gateway path resolved: ${_p.segment}"
        "\nfull: ${request.path.processed}");

    if (_p.segment.isUnknown) {
      return binding.unknown.call(request);
    }
    return components[_p.segment]!.call(request);
  }
}

// mixin GatewayMixin on CallingComponent {
//   Map<PathSegment, Component> get children;
//
//   Endpoint get unknown;
//
//   Endpoint? get defaultEndpoint;
// }
//
// class Gateway extends CallingComponent with GatewayMixin {
//   Gateway(
//       {Endpoint? unknown,
//       Endpoint? root,
//       required PathSegment segment,
//       required Map<PathSegment, Component> children})
//       : _segment = segment,
//         _root = root ?? UnknownEndpoint(),
//         _unknown = unknown ?? UnknownEndpoint(),
//         _children = children,
//         super();
//
//   /// s
//   final PathSegment _segment;
//
//   final Endpoint _unknown;
//
//   final Endpoint _root;
//   final Map<PathSegment, Component> _children;
//
//   @override
//   Endpoint get unknown => _unknown;
//
//   @override
//   Endpoint? get defaultEndpoint => _root;
//
//   @override
//   Map<PathSegment, Component> get children => _children;
//
//   @override
//   GatewayBinding createBinding() => GatewayBinding(this);
//
//   /// e
//   @override
//   Calling createCalling(BuildContext context) =>
//       GatewayCalling(context as Binding);
// }
//
// class GatewayBinding extends CallingBinding with PathSegmentBindingMixin {
//   GatewayBinding(Gateway component) : super(component);
//
//   @override
//   Gateway get component => super.component as Gateway;
//
//   late List<Binding> children;
//
//   @override
//   PathSegment get segment => component._segment;
//
//   /// Bir map yap buildde
//   /// Bu mapde callingler bulunsun
//   ///
//   @override
//   void _build() {
//     _calling = component.createCalling(this);
//
//     var _bindings = <Binding>[];
//     for (var element in component.children.entries) {
//       _bindings.add(element.value.createBinding());
//     }
//     children = _bindings;
//
//     for (var bind in children) {
//       bind.attachToParent(this, _owner);
//       bind._build();
//     }
//   }
//
//   @override
//   TreeVisitor<Calling> callingVisitor(TreeVisitor<Calling> visitor) {
//     visitor(calling);
//     if (!visitor._stopped) {
//       for (var child in children) {
//         child.visitCallingChildren(visitor);
//       }
//     }
//     return visitor;
//   }
// }
//
// class GatewayCalling extends Calling {
//   GatewayCalling(Binding binding) : super(binding: (binding as CallingBinding));
//
//   @override
//   FutureOr<void> onCall(Request request) {
//     // TODO: implement onCall
//     throw UnimplementedError();
//   }
// }

///
///
///
///
///
/// First of all, thank you for bringing this great game. I have a few suggestions that the audience playing this game will enjoy and that can make the game much better.
///
/// 1) Technologies: It can get much more complex. Civilization Series can be taken as an example. For example, "Tailoring" is a pretty big area to be explored in one go.
/// Adding one more requirement for Tech Discovery allows the player to play through all tiers of technology. This requirement may be experience from previous exploration
///
/// Example "Construction" tech tree;
/// "Basic Construction": Used in the construction of the simplest buildings, invisible to the user, discovered, unstable (especially trapezoidal) wood columns and only bush ground and bush and straw roof.
///
/// "Woodworking" : Requires X Experience Points earned in Basic Construction and Y books. Beam, Wooden Column, Wooden Roof etc.
///
/// "Stone Processing" , "Mortar" , "Concrete" (Only more solid) ...
///
/// 2) Statistics: Players are very used to statistics and map layers. I felt the absence of it so much. Different map layers are required showing Minerals, Temperature, Animals, Yield, Durability, Collectibles. It would also be good to select and colorize data such as people's happiness on people. Thus, much larger populations can be managed.
/// In addition, I need to find answers to questions such as how many people are deprived of entertainment in Statistics.
///
/// 3) Roads and Trade: Considering that trade will be added, the "road" is a great need. Cleanable (Snow etc) roads are important for the operation of more complex supply chains :)
/// Why am I talking about such a supply chain?
/// Because I think you need a more complex trading system compared to banished and down of man. A large managed trading panel would be better than trade that is expected and actionable every time. In this panel, the productions and needs of the regions can be found. These supply-demand quantities must be variable. Trade can be developed by using diplomacy with the peoples of the region. Trade routes can be established.
/// In short, a trading with a complex variable supply-demand balance can perfect the game. Resource differences between regions increase, the variety of products used increases and can be managed thanks to this panel.
///
/// 4) Cube: If Cube is used instead of Rectangular Prism, construction can be made more complex and beautiful. Cross-cut columns and floors are also good.
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
///
