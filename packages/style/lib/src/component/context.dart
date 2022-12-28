/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE,
 *    Version 3 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       https://www.gnu.org/licenses/agpl-3.0.en.html
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

part of '../style_base.dart';

///
abstract class BuildContext {
  ///
  ServerBinding get owner => _owner!;

  ServerBinding? _owner;

  Binding? _parent;

  void _setServiceToThisAndParents<B extends BaseService>(B newService,
      {bool onChild = false}) {
    if (B == Crypto) {
      if (onChild && _crypto != null) return;
      if (onChild) {
        _crypto ??= newService as Crypto;
      } else {
        _crypto = newService as Crypto;
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
    } else if (B == HttpService) {
      if (onChild && _httpService != null) return;
      if (onChild) {
        _httpService ??= newService as HttpService;
      } else {
        _httpService = newService as HttpService;
      }
    } else if (B == Logger) {
      if (onChild && _logger != null) return;
      if (onChild) {
        _logger ??= newService as Logger;
      } else {
        _logger = newService as Logger;
      }
    } else if (B == Authorization) {
      if (onChild && _authorization != null) return;
      if (onChild) {
        _authorization ??= newService as Authorization;
      } else {
        _authorization = newService as Authorization;
      }
    } else {}
    _parent?._setServiceToThisAndParents(newService, onChild: true);
  }

  ///
  Component get component;

  Crypto? _crypto;

  ///
  Crypto get crypto => _crypto!;

  ///
  bool hasService<T extends BaseService>() {
    if (T == DataAccess) {
      return _dataAccess != null;
    } else if (T == WebSocketService) {
      return _socketService != null;
    } else if (T == HttpService) {
      return _httpService != null;
    } else if (T == Crypto) {
      return _crypto != null;
    } else if (T == Logger) {
      return _logger != null;
    } else if (T == Authorization) {
      return _authorization != null;
    } else {
      return false;
    }
  }

  DataAccess? _dataAccess;

  ///
  DataAccess get dataAccess {
    if (_dataAccess == null) {
      throw ServiceUnavailable('data_access');
    }
    return _dataAccess!;
  }

  WebSocketService? _socketService;

  ///
  WebSocketService get socketService {
    if (_socketService == null) {
      throw ServiceUnavailable('socket_service');
    }

    return _socketService!;
  }

  Authorization? _authorization;

  ///
  Authorization get authorization {
    if (_authorization == null) {
      throw ServiceUnavailable('authorization');
    }

    return _authorization!;
  }

  ///
  HttpService? _httpService;

  ///
  HttpService get httpService {
    if (_httpService == null) {
      throw ServiceUnavailable('http_service');
    }
    return _httpService!;
  }

  Logger? _logger;

  ///
  Logger get logger {
    if (_logger == null) {
      throw ServiceUnavailable('logger');
    }
    return _logger!;
  }

  ///
  T? findAncestorBindingOfType<T extends Binding>();

  ///
  T? findAncestorComponentOfType<T extends Component>();

  ///
  T? findAncestorServiceByName<T extends ServerBinding>(String name);

  ///
  T? findAncestorStateOfType<T extends State<StatefulComponent>>();

  ///
  T? findAncestorStateOfKey<T extends GlobalKey<State<StatefulComponent>>>(
      String key);

  ///
  T? findChildService<T extends ServerBinding>();

  ///
  T? findChildState<T extends State>();

  ///
  CallingBinding get findCalling;

  ///
  CallingBinding? get ancestorCalling;

  ///
  ExceptionHandler get exceptionHandler;

  /// Get current context path
  String getPath() {
    BuildContext? parent = this;
    var segments = <PathSegment>[];
    while (parent != null && parent is! ServiceOwnerMixin) {
      if ((parent as Binding?) is RouteBinding) {
        segments.add((parent as RouteBinding).component.segment);
      }
      parent = parent._parent;
    }
    return "/${segments.map((e) => e.name).join("/")}";
  }
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

    Binding? anc = this;
    while (anc != null) {
      if (anc.component is! ServiceWrapper) {
        list.add(anc.component.runtimeType);
      }
      anc = anc._parent;
    }
    return list.reversed.join(' -> ');
  }

  @override
  ExceptionHandler get exceptionHandler => _exceptionHandler!;

  ExceptionHandler? _exceptionHandler;

  ///
  void attachToParent(Binding parent) {
    _owner = parent._owner;
    _parent = parent;
    _exceptionHandler = parent._exceptionHandler?.copyWith();

    /// Base services
    _crypto = parent._crypto;
    _httpService = parent._httpService;
    _socketService = parent._socketService;
    _dataAccess = parent._dataAccess;
    _authorization = parent._authorization;
    _logger = parent._logger;
  }

  ///
  TreeVisitor<Binding> visitChildren(TreeVisitor<Binding> visitor) {
    if (visitor.stopped) return visitor;
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
  T? findAncestorServiceByName<T extends ServerBinding>(String name) {
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
  T? findAncestorStateOfKey<T extends GlobalKey<State<StatefulComponent>>>(
      String key) {
    var ancestor = _parent;
    while (ancestor != null &&
        !(ancestor is StatefulBinding &&
            ancestor.state.key is T &&
            ancestor.state.key.key == key)) {
      ancestor = ancestor._parent;
    }
    return (ancestor as StatefulBinding?)?.state.key as T?;
  }

  @override
  T? findChildService<T extends ServerBinding>() {
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
  CallingBinding get findCalling =>
      _foundCalling ??= visitCallingChildren(TreeVisitor((visitor) {
        visitor.stop();
      })).currentValue.binding;

  CallingBinding? _foundCalling;

  @override
  CallingBinding? get ancestorCalling {
    Binding? result;
    var ancestor = _parent;
    while (ancestor != null && result == null && ancestor is! ServerBinding) {
      if (ancestor is CallingBinding) {
        result = ancestor;
        break;
      }
      ancestor = ancestor._parent;
    }

    return result as CallingBinding?;
  }

  ///
  void buildBinding();

  ///
// Map<String, dynamic> toMapShort() => {
//       "component": component.runtimeType.toString(),
//       "key": key.key,
//       "type": runtimeType.toString(),
//     };
//
// ///
// Map<String, dynamic> toMapOwn() => {
//       "calling": _foundCalling?.toMapShort(),
//       "services": [
//         if (hasService<DataAccess>())
//           {"type": "data_access", "name": dataAccess.runtimeType
//           .toString()},
//         if (hasService<Logger>())
//           {"type": "logger", "name": logger.runtimeType.toString()},
//         if (hasService<HttpService>())
//           {
//             "type": "http_service",
//             "name": httpService.runtimeType.toString()
//           },
//         if (hasService<WebSocketService>())
//           {
//             "type": "web_socket",
//             "name": socketService.runtimeType.toString()
//           },
//         if (hasService<Crypto>())
//           {"type": "crypto", "name": crypto.runtimeType.toString()},
//         if (hasService<Authorization>())
//           {
//             "type": "authorization",
//             "name": authorization.runtimeType.toString()
//           },
//       ]
//     };
}

///
class TreeVisitor<T> {
  ///
  TreeVisitor(this.visitor);

  ///
  void Function(TreeVisitor<T> visitor)? visitor;

  ///
  bool stopped = false;

  ///
  late T currentValue;

  ///
  void call(T value) {
    if (stopped) throw Exception('Add stop checker');
    currentValue = value;
    visitor!.call(this);
  }

  ///
  void stop() {
    result = currentValue;
    stopped = true;
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

  ///
  Binding? child;

  ///
  Component build(Binding binding);

  @override
  TreeVisitor<Binding> visitChildren(TreeVisitor<Binding> visitor) {
    if (visitor.stopped) return visitor;
    visitor(this);
    child!.visitChildren(visitor);
    return visitor;
  }

  @override
  TreeVisitor<Calling> visitCallingChildren(TreeVisitor<Calling> visitor) =>
      child!.visitCallingChildren(visitor);

  @override
  void buildBinding() {
    /// Build this binding component
    /// create child's binding
    /// attach this
    child = null;
    var childComponent = build(this);
    child = childComponent.createBinding();
    child!.attachToParent(this);
    child!.buildBinding();
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
    if (visitor.stopped) return visitor;
    visitor(this);
    child!.visitChildren(visitor);
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
    if (visitor.stopped) return visitor;
    visitor(this);
    child!.visitChildren(visitor);
    return visitor;
  }

  @override
  Component build(Binding binding) {
    _state ??= (component).createState();
    _state!._component = component;
    _state!._binding = this;
    _state!.initState();
    if (binding._owner != null && binding.key is GlobalKey) {
      (binding.key as GlobalKey).binding = this;
      _owner!.addState(state);
    }
    return _state!.build(binding);
  }
}
