part of '../style_base.dart';

abstract class BuildContext {
  @override
  ServiceBinding get owner => _owner!;
  ServiceBinding? _owner;
  Binding? _parent;

  ///
  Component get component;

  CryptoService? _crypto;

  ///
  CryptoService get crypto => _crypto!;

  DataAccess? _dataAccess;

  ///
  DataAccess get dataAccess => _dataAccess!;

  WebSocketService? _socketService;

  ///
  WebSocketService get socketService => _socketService!;

  HttpServiceHandler? _httpService;

  ///
  HttpServiceHandler get httpService => _httpService!;

  T? findAncestorBindingOfType<T extends Binding>();

  T? findAncestorComponentOfType<T extends Component>();

  T? findAncestorServiceByName<T extends ServiceBinding>(String name);

  T? findAncestorStateOfType<T extends State<StatefulComponent>>();

  T? findChildService<T extends ServiceBinding>();

  T? findChildState<T extends State>();

  CallingBinding get findCalling;

  CallingBinding? get ancestorCalling;

  Binding get unknown => _unknown!;

  Binding? _unknown;
}

/// Mimari kurucusu
/// Gerekli işlemleri gerekli yollara ekler
///
/// Aynı zamanda component ve calling  arasındaki köprüdür.
///
/// Binding ağacı bitince dökümantasyon oluşturulur
///
/// Binding aynı zamanda bir context'tir
///
/// Context yalnızca build esnasında gerekli olan bilgileri taşır
abstract class Binding extends BuildContext {
  Binding(Component component)
      : _component = component,
        _key = component.key ?? Key.random(),
        super();

  ///Calling get calling;

  Key get key => _key;

  final Key _key;

  final Component _component;

  @override
  Component get component => _component;


  ///
  FutureOr<Message> call(Request request);


  void attachToParent(Binding parent) {
   //  print("""
   //  Attaching: $this
   // owner: ${parent._owner}
   // parent: $parent
   // crypt: ${parent._crypto}
   // unknown: ${parent._unknown}
   // http: ${parent._httpService}
   // socket: ${parent._socketService}
   // data: ${parent._dataAccess}
   //  """);
    _owner = parent._owner;
    _parent = parent;
    _crypto = parent._crypto;
    _unknown = parent._unknown;
    _httpService = parent._httpService;
    _socketService = parent._socketService;
    _dataAccess = parent._dataAccess;
  }

  TreeVisitor<Binding> visitChildren(TreeVisitor<Binding> visitor) {
    return visitor;
  }

  TreeVisitor<Calling> visitCallingChildren(TreeVisitor<Calling> visitor);

  @override
  T? findAncestorBindingOfType<T extends Binding>() {
    var ancestor = _parent;
    while (ancestor != null && ancestor.runtimeType != T) {
      ancestor = ancestor._parent;
    }
    return ancestor as T?;
  }

  @override
  T? findAncestorComponentOfType<T extends Component>() {
    var ancestor = _parent;
    while (ancestor != null && ancestor.component.runtimeType != T) {
      ancestor = ancestor._parent;
    }
    return ancestor?.component as T?;
  }

  @override
  T? findAncestorServiceByName<T extends ServiceBinding>(String name) {
    Binding? ancestor = _owner;
    while (ancestor != null &&
        !(ancestor is T && ((ancestor).serviceRootName == name))) {
      ancestor = ancestor._owner;
    }
    return ancestor as T?;
  }

  @override
  T? findAncestorStateOfType<T extends State<StatefulComponent>>() {
    var ancestor = _parent;
    while (ancestor != null &&
        !(ancestor is StatefulBinding && ancestor.state is T)) {
      ancestor = ancestor._parent;
    }
    return (ancestor as StatefulBinding?)?.state as T?;
  }

  @override
  T? findChildService<T extends ServiceBinding>() {
    var visiting = visitChildren(TreeVisitor<Binding>((visitor) {
      if (visitor.currentValue is T) {
        visitor.stop(visitor.currentValue);
      }
    }));

    return visiting.result as T;
  }

  @override
  T? findChildState<T extends State>() {
    var visiting = visitChildren(TreeVisitor<Binding>((visitor) {
      if (visitor.currentValue is StatefulBinding &&
          (visitor.currentValue as StatefulBinding).state is T) {
        visitor.stop(visitor.currentValue);
      }
    }));

    return (visiting.result as StatefulBinding?)?.state as T?;
  }

  @override
  CallingBinding get findCalling {
    return visitCallingChildren(TreeVisitor((visitor) {
      visitor.stop(visitor.currentValue);
    })).currentValue.binding;
  }

  @override
  CallingBinding? get ancestorCalling {
    Binding? result;
    var ancestor = _parent;
    while (ancestor != null && result == null && ancestor is! ServiceBinding) {
      if (ancestor is CallingBinding) {
        result = ancestor;
        break;
      }
      ancestor = ancestor._parent;
    }

    return result as CallingBinding?;
  }

  void _build();
}

class TreeVisitor<T> {
  TreeVisitor(this.visitor);

  void Function(TreeVisitor<T> visitor)? visitor;

  bool _stopped = false;

  late T currentValue;

  void call(T value) {
    currentValue = value;
    visitor!.call(this);
  }

  void stop(T value) {
    result = value;
    _stopped = true;
  }

  T? result;
}

typedef BindingVisitor = void Function(Binding binding);

abstract class DevelopmentBinding extends Binding {
  DevelopmentBinding(Component component) : super(component);

  Binding? _child;

  Component build(Binding binding);

  @override
  TreeVisitor<Binding> visitChildren(TreeVisitor<Binding> visitor) {
    visitor(this);
    _child!.visitChildren(visitor);
    return visitor;
  }

  @override
  TreeVisitor<Calling> visitCallingChildren(TreeVisitor<Calling> visitor) {
    return _child!.visitCallingChildren(visitor);
  }

  @override
  void _build() {
    /// Build this binding component
    /// create child's binding
    /// attach this
    _child = null;
    var _childComponent = build(this);
    _child = _childComponent.createBinding();
    _child!.attachToParent(this);
    _child!._build();
  }
}

class StatelessBinding extends DevelopmentBinding {
  StatelessBinding(StatelessComponent component) : super(component);

  @override
  StatelessComponent get component => super.component as StatelessComponent;

  @override
  Component build(Binding binding) => component.build(binding);

  @override
  Key get key => _key;

  @override
  TreeVisitor<Binding> visitChildren(TreeVisitor<Binding> visitor) {
    visitor(this);
    _child!.visitChildren(visitor);
    return visitor;
  }

  @override
  FutureOr<Message> call(Request request) {
    return _child!.call(request);
  }
}

class StatefulBinding extends DevelopmentBinding {
  StatefulBinding(StatefulComponent component) : super(component);

  bool get initialized => _state != null;

  State get state => _state!;

  State? _state;

  @override
  StatefulComponent get component => super.component as StatefulComponent;

  @override
  TreeVisitor<Binding> visitChildren(TreeVisitor<Binding> visitor) {
    visitor(this);
    _child!.visitChildren(visitor);
    return visitor;
  }

  @override
  Component build(Binding binding) {
    _state ??= (component).createState();
    _state!._component = component;
    _state!._binding = this;
    _state!.initState();
    if (binding._owner != null && binding.key is GlobalKey) {
      _owner!.addState(state);
    }
    return _state!.build(binding);
  }

  @override
  FutureOr<Message> call(Request request) {
    return _child!.call(request);
  }
}
