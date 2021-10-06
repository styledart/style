part of '../style_base.dart';

/// Ana Mimarideki her bir parça
///
@immutable
abstract class Component {
  ///
  const Component({this.key});

  ///
  final Key? key;

  ///
  Binding createBinding();

  ///
  String toStringDeep() {
    // TODO: implement toStringDeep
    throw UnimplementedError();
  }

  ///
  String toStringSort() {
    // TODO: implement toStringSort
    throw UnimplementedError();
  }
}

///
abstract class StatelessComponent extends Component {
  ///
  const StatelessComponent({Key? key}) : super(key: key);

  @override
  StatelessBinding createBinding() => StatelessBinding(this);

  ///
  Component build(BuildContext context);

  @override
  String toStringDeep() {
    // TODO: implement toStringDeep
    throw UnimplementedError();
  }

  @override
  String toStringSort() {
    // TODO: implement toStringSort
    throw UnimplementedError();
  }
}

///
abstract class StatefulComponent extends Component {
  ///
  const StatefulComponent({Key? key}) : super(key: key);

  ///
  State<StatefulComponent> createState();

  ///
  @override
  StatefulBinding createBinding() => StatefulBinding(this);
}

///
abstract class State<T extends StatefulComponent> {
  ///
  bool get mounted => _binding != null;

  ///
  Component build(BuildContext context);

  T? _component;

  ///
  T get component => _component!;

  StatefulBinding? _binding;

  ///
  StatefulBinding get context => _binding!;

  ///
  void initState() async {}
}

///
class Key {
  ///
  const Key(this.key);

  ///
  Key.random() : key = getRandomId(20);

  ///
  final String key;
}

///
@immutable
class GlobalKey<T extends State<StatefulComponent>> extends Key {
  ///
  GlobalKey(String key) : super(key);

  ///
  GlobalKey.random() : super.random();

  ///
  late final StatefulBinding? binding;

  ///
  T get currentState {
    assert(binding != null);
    return binding!.state as T;
  }

  ///
  bool get mounted => binding != null && binding!._state != null;

  @override
  bool operator ==(Object other) {
    return other is GlobalKey<T> && other.key == key;
  }

  late final int? _hashCode;

  @override
  int get hashCode => _hashCode ??= Object.hash(key, T);
}

/// TODO:
abstract class CallingComponent extends Component {
  /// TODO:
  const CallingComponent({Key? key}) : super(key: key);

  @override
  CallingBinding createBinding();

  ///
  Calling createCalling(BuildContext context);

  @override
  String toStringDeep() {
    // TODO: implement toStringDeep
    throw UnimplementedError();
  }

  @override
  String toStringSort() {
    // TODO: implement toStringSort
    throw UnimplementedError();
  }
}

///
abstract class SingleChildCallingComponent extends CallingComponent {
  ///
  SingleChildCallingComponent(this.child);

  ///
  final Component child;

  @override
  SingleChildCallingBinding createBinding();
}

///
abstract class MultiChildCallingComponent extends CallingComponent {
  ///
  MultiChildCallingComponent(this.children);

  ///
  final List<Component> children;

  @override
  MultiChildCallingBinding createBinding() => MultiChildCallingBinding(this);
}

/// Server
/// Service
///
/// MultiChild,
/// SingleChild,
/// Endpoint
abstract class CallingBinding extends Binding {
  ///
  CallingBinding(CallingComponent component) : super(component);

  @override
  CallingComponent get component => super.component as CallingComponent;

  ///
  Calling get calling => _calling!;

  Calling? _calling;

  ///
  TreeVisitor<Calling> callingVisitor(TreeVisitor<Calling> visitor);

  @override
  TreeVisitor<Calling> visitCallingChildren(TreeVisitor<Calling> visitor) {
    return callingVisitor(visitor);
  }
}

///
abstract class SingleChildBindingComponent extends StatelessComponent {
  ///
  SingleChildBindingComponent(this.child);

  ///
  final Component child;

  ///
  SingleChildBinding createCustomBinding();
}

///
class SingleChildBinding extends Binding {
  ///
  SingleChildBinding(Component component) : super(component);

  @override
  SingleChildCallingComponent get component =>
      super.component as SingleChildCallingComponent;

  late Binding _child;

  ///
  Binding get child => _child;

  @override
  void _build() {
    _child = component.child.createBinding();

    // print("Single Child Building: comp: ${component.runtimeType}\n"
    //     "_child: $_child\n"
    //     "_childComps: $_child");

    _child.attachToParent(this);
    _child._build();
  }

  @override
  TreeVisitor<Calling> visitCallingChildren(TreeVisitor<Calling> visitor) {
    // TODO: implement visitCallingChildren
    throw UnimplementedError();
  }
}

///
class SingleChildCallingBinding extends CallingBinding {
  ///
  SingleChildCallingBinding(SingleChildCallingComponent component)
      : super(component);

  @override
  SingleChildCallingComponent get component =>
      super.component as SingleChildCallingComponent;

  late Binding _child;

  ///
  Binding get child => _child;

  @override
  void _build() {
    _calling = component.createCalling(this);
    _child = component.child.createBinding();

    // print("Single Child Building: comp: ${component.runtimeType}\n"
    //     "_child: $_child\n"
    //     "_childComps: $_child");

    _child.attachToParent(this);
    _child._build();
  }

  @override
  TreeVisitor<Calling> callingVisitor(TreeVisitor<Calling> visitor) {
    if (visitor._stopped) return visitor;
    visitor(calling);
    return child.visitCallingChildren(visitor);
  }
}

///
class MultiChildCallingBinding extends CallingBinding {
  ///
  MultiChildCallingBinding(MultiChildCallingComponent component)
      : super(component);

  @override
  MultiChildCallingComponent get component =>
      super.component as MultiChildCallingComponent;

  ///
  late List<Binding> children;

  /// Bir map yap buildde
  /// Bu mapde callingler bulunsun
  ///
  @override
  void _build() {
    var _bindings = <Binding>[];
    for (var element in component.children) {
      _bindings.add(element.createBinding());
    }
    children = _bindings;
    for (var bind in children) {
      bind.attachToParent(this);
      bind._build();
    }
    _calling = component.createCalling(this);
  }

  @override
  TreeVisitor<Calling> callingVisitor(TreeVisitor<Calling> visitor) {
    if (visitor._stopped) return visitor;
    visitor(calling);
    if (!visitor._stopped) {
      for (var child in children) {
        child.visitCallingChildren(visitor);
      }
    }
    return visitor;
  }

  @override
  TreeVisitor<Binding> visitChildren(TreeVisitor<Binding> visitor) {
    if (visitor._stopped) return visitor;
    visitor(this);
    if (!visitor._stopped) {
      //
      for (var bind in children) {
        bind.visitChildren(visitor);
      }
    }
    return visitor;
    //
    // visitor(this);
    // for (var bind in _childrenBindings ?? <Binding>[]) {
    //   bind.visitChildren(visitor);
    // }
  }
}
