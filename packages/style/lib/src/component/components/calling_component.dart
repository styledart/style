part of '../../style_base.dart';

abstract class CallingComponent extends Component {
  @override
  CallingBinding createBinding();

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

abstract class SingleChildCallingComponent
    extends CallingComponent {
  SingleChildCallingComponent(this.child);

  final Component? child;

  @override
  SingleChildCallingBinding createBinding();
}

abstract class MultiChildCallingComponent
    extends CallingComponent {
  MultiChildCallingComponent( this.children);



  final List<Component> children;

  @override
  MultiChildCallingBinding createBinding() =>
      MultiChildCallingBinding(this);
}

/// Server
/// Service
///
/// MultiChild,
/// SingleChild,
/// Endpoint
abstract class CallingBinding extends Binding {
  CallingBinding(CallingComponent component)
      : super(component);

  @override
  CallingComponent get component =>
      super.component as CallingComponent;

  Calling get calling => _calling!;

  Calling? _calling;

  TreeVisitor<Calling> callingVisitor(
      TreeVisitor<Calling> visitor);

  @override
  TreeVisitor<Calling> visitCallingChildren(
      TreeVisitor<Calling> visitor) {
    return callingVisitor(visitor);
  }
}

class SingleChildCallingBinding extends CallingBinding {
  SingleChildCallingBinding(
      SingleChildCallingComponent component)
      : super(component);

  @override
  SingleChildCallingComponent get component =>
      super.component as SingleChildCallingComponent;

  Binding? _child;

  Binding? get child => _child!;

  @override
  void _build() {
    _calling = component.createCalling(this);
    var _childComponents = component.child ?? unknown;
    _child = _childComponents.createBinding();
    _child!.attachToParent(this, _owner);
    _child!._build();
  }

  @override
  TreeVisitor<Calling> callingVisitor(
      TreeVisitor<Calling> visitor) {
    visitor(calling);
    return child?.visitCallingChildren(visitor) ?? visitor;
  }
}

class MultiChildCallingBinding extends CallingBinding {
  MultiChildCallingBinding(
      MultiChildCallingComponent component)
      : super(component);

  @override
  MultiChildCallingComponent get component =>
      super.component as MultiChildCallingComponent;

  late List<Binding> children;

  /// Bir map yap buildde
  /// Bu mapde callingler bulunsun
  ///
  @override
  void _build() {
    _calling = component.createCalling(this);

    var _bindings = <Binding>[];
    for (var element in component.children) {
      _bindings.add(element.createBinding());
    }
    children = _bindings;

    for (var bind in children) {
      bind.attachToParent(this, _owner);
      bind._build();
    }
  }

  @override
  TreeVisitor<Calling> callingVisitor(
      TreeVisitor<Calling> visitor) {
    visitor(calling);
    if (!visitor._stopped) {
      for (var child in children) {
        child.visitCallingChildren(visitor);
      }
    }
    return visitor;
  }
}
