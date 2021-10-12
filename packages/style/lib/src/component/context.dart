part of '../style_base.dart';

///
abstract class BuildContext {
  ///
  ServiceBinding get owner => _owner!;

  ServiceBinding? _owner;

  Binding? _parent;

  void _setServiceToThisAndParents<B extends _BaseService>(B newService,
      {bool onChild = false}) {
    if (B == CryptoService) {
      if (onChild && _crypto != null) return;
      if (onChild) {
        _crypto ??= newService as CryptoService;
      } else {
        _crypto = newService as CryptoService;
      }
    } else if (B == DataAccess) {
      if (onChild && _dataAccess != null) return;
      if (onChild) {
        _dataAccess ??= newService as DataAccess;
      } else {
        _dataAccess = newService as DataAccess;
      }
    } else if (B == WebSocketService) {
      if (onChild && _socketService != null) return;
      if (onChild) {
        _socketService ??= newService as WebSocketService;
      } else {
        _socketService = newService as WebSocketService;
      }
    } else if (B == HttpServiceHandler) {
      if (onChild && _httpService != null) return;
      if (onChild) {
        _httpService ??= newService as HttpServiceHandler;
      } else {
        _httpService = newService as HttpServiceHandler;
      }
    } else if (B == Logger) {
      if (onChild && _logger != null) return;
      if (onChild) {
        _logger ??= newService as Logger;
      } else {
        _logger = newService as Logger;
      }
      print("Logger Settings : $newService");
    }
    _parent?._setServiceToThisAndParents<B>(newService, onChild: true);
  }

  ///
  Component get component;

  CryptoService? _crypto;

  ///
  CryptoService get crypto => _crypto!;

  DataAccess? _dataAccess;

  ///
  DataAccess get dataAccess {
    if (_dataAccess == null) {
      throw ServiceUnavailable("data_access");
    }
    return _dataAccess!;
  }

  WebSocketService? _socketService;

  ///
  WebSocketService get socketService => _socketService!;

  HttpServiceHandler? _httpService;

  ///
  HttpServiceHandler get httpService => _httpService!;

  Logger? _logger;

  ///
  Logger get logger => _logger!;

  ///
  T? findAncestorBindingOfType<T extends Binding>();

  ///
  T? findAncestorComponentOfType<T extends Component>();

  ///
  T? findAncestorServiceByName<T extends ServiceBinding>(String name);

  ///
  T? findAncestorStateOfType<T extends State<StatefulComponent>>();

  ///
  T? findChildService<T extends ServiceBinding>();

  ///
  T? findChildState<T extends State>();

  ///
  CallingBinding get findCalling;

  ///
  CallingBinding? get ancestorCalling;

  ///
  ExceptionHandler get exceptionHandler;
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
  ///
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

  String get _errorWhere {
    var list = <Type>[];

    Binding? _anc = this;
    while (_anc != null) {
      if (_anc.component is! ServiceWrapper) {
        list.add(_anc.component.runtimeType);
      }
      _anc = _anc._parent;
    }
    return list.reversed.join(" -> ");
  }

  ExceptionHandler get exceptionHandler => _exceptionHandler!;

  ExceptionHandler? _exceptionHandler;

  ///
  void attachToParent(Binding parent) {
    _owner = parent._owner;
    _parent = parent;
    _crypto = parent._crypto;
    _exceptionHandler = parent._exceptionHandler?.copyWith();
    _httpService = parent._httpService;
    _socketService = parent._socketService;
    _dataAccess = parent._dataAccess;
    _logger = parent._logger;
    print(
        "Parent Attached in With ${parent._logger}   : ${parent._httpService}  : ${parent._dataAccess}");
  }

  ///
  TreeVisitor<Binding> visitChildren(TreeVisitor<Binding> visitor) {
    if (visitor._stopped) return visitor;
    return visitor;
  }

  ///
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
        visitor.stop();
      }
    }));

    return visiting.result as T;
  }

  @override
  T? findChildState<T extends State>() {
    var visiting = visitChildren(TreeVisitor<Binding>((visitor) {
      if (visitor.currentValue is StatefulBinding &&
          (visitor.currentValue as StatefulBinding).state is T) {
        visitor.stop();
      }
    }));

    return (visiting.result as StatefulBinding?)?.state as T?;
  }

  @override
  CallingBinding get findCalling {
    return _foundCalling ??= visitCallingChildren(TreeVisitor((visitor) {
      visitor.stop();
    })).currentValue.binding;
  }

  CallingBinding? _foundCalling;

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

///
class TreeVisitor<T> {
  ///
  TreeVisitor(this.visitor);

  ///
  void Function(TreeVisitor<T> visitor)? visitor;

  bool _stopped = false;

  ///
  late T currentValue;

  ///
  void call(T value) {
    if (_stopped) throw Exception("Add stop checker");
    currentValue = value;
    visitor!.call(this);
  }

  ///
  void stop() {
    result = currentValue;
    _stopped = true;
  }

  ///
  T? result;
}

///
typedef BindingVisitor = void Function(Binding binding);

///
abstract class DevelopmentBinding extends Binding {
  ///
  DevelopmentBinding(Component component) : super(component);

  Binding? _child;

  ///
  Component build(Binding binding);

  @override
  TreeVisitor<Binding> visitChildren(TreeVisitor<Binding> visitor) {
    if (visitor._stopped) return visitor;
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

///
class StatelessBinding extends DevelopmentBinding {
  ///
  StatelessBinding(StatelessComponent component) : super(component);

  @override
  StatelessComponent get component => super.component as StatelessComponent;

  @override
  Component build(Binding binding) => component.build(binding);

  @override
  Key get key => _key;

  @override
  TreeVisitor<Binding> visitChildren(TreeVisitor<Binding> visitor) {
    if (visitor._stopped) return visitor;
    visitor(this);
    _child!.visitChildren(visitor);
    return visitor;
  }
}

///
class StatefulBinding extends DevelopmentBinding {
  ///
  StatefulBinding(StatefulComponent component) : super(component);

  ///
  bool get initialized => _state != null;

  ///
  State get state => _state!;

  State? _state;

  @override
  StatefulComponent get component => super.component as StatefulComponent;

  @override
  TreeVisitor<Binding> visitChildren(TreeVisitor<Binding> visitor) {
    if (visitor._stopped) return visitor;
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
}
