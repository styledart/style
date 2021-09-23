part of '../../style_base.dart';

///
class Server extends StatefulComponent {
  ///
  Server(
      {GlobalKey? key,
      HttpServiceHandler? httpServiceNew,
      WebSocketService? socketService,
      DataAccess? dataAccess,
      CryptoService? cryptoService,
      String? rootName,
      Endpoint? rootEndpoint,
      Endpoint? defaultUnknownEndpoint,
      required this.children})
      : httpServiceNew = httpServiceNew ?? DefaultHttpServiceHandler(),
        socketService = socketService ?? DefaultSocketServiceHandler(),
        dataAccess = dataAccess ?? DefaultDataAccessHandler(),
        cryptoService = cryptoService ?? DefaultCryptoHandler(),
        rootName = rootName ?? "style_server",
        rootEndpoint =
            rootEndpoint ?? defaultUnknownEndpoint ?? UnknownEndpoint(),
        unknown = defaultUnknownEndpoint ?? UnknownEndpoint(),
        super(key: key ?? GlobalKey<ServiceState>.random());

  ///
  final String rootName;

  ///
  final CryptoService cryptoService;

  ///
  final DataAccess dataAccess;

  ///
  final WebSocketService socketService;

  ///
  final HttpServiceHandler httpServiceNew;

  ///
  final List<PathRouter> children;

  ///
  final Endpoint unknown;

  ///
  final Endpoint rootEndpoint;

  @override
  State<StatefulComponent> createState() => ServiceState();
}

///
class ServiceState extends State<Server> {
  ///
  String get rootName => component.rootName;

  ///
  CryptoService get cryptoService => component.cryptoService;

  ///
  DataAccess get dataAccess => component.dataAccess;

  ///
  WebSocketService get socketService => component.socketService;

  ///
  HttpServiceHandler get httpServiceNew => component.httpServiceNew;

  @override
  Component build(BuildContext context) {
    // final _components = component.children.map((key, value) =>
    //     MapEntry(PathSegment(key), PathRouter(segment: key, child: value)));
    // assert(() {
    //   var argCount = 0;
    //   for (var seg in _components.entries) {
    //     if (seg.key is ArgumentSegment) {
    //       argCount++;
    //     }
    //   }
    //   return argCount < 2;
    // }(), "Gateway Allow only 1 argument segment");

    return ServiceCallingComponent(
        rootName: rootName,
        child: _BaseServiceComponent<DataAccess>(
          service: dataAccess,
          child: _BaseServiceComponent<WebSocketService>(
            service: socketService,
            child: _BaseServiceComponent<CryptoService>(
                service: cryptoService,
                child: _BaseServiceComponent<HttpServiceHandler>(
                    service: httpServiceNew,
                    child: Gateway(children: component.children))),
          ),
        ),
        unknown: component.unknown,
        root: component.rootEndpoint);

    // return DataAccess(
    //   key: GlobalKey<DataAccessState>.random(),
    //   dataAccessHandler: dataAccess,
    //   child: SocketService(
    //     key: GlobalKey<SocketServiceState>.random(),
    //     socketServiceHandler: socketService,
    //     child: HttpService(
    //         key: GlobalKey<HttpServiceState>.random(),
    //         httpServiceHandler: httpServiceNew,
    //         child: CryptoComponent(
    //             key: GlobalKey<CryptoState>.random(),
    //             cryptoHandler: cryptoService,
    //             child: ServiceCallingComponent(
    //                 httpServiceNew: httpServiceNew,
    //                 socketService: socketService,
    //                 dataAccess: dataAccess,
    //                 cryptoService: cryptoService,
    //                 rootName: rootName,
    //                 root: component.rootEndpoint,
    //                 unknown: component.unknown,
    //                 children: _components))),
    //   ),
    // );
  }
}

///
class ServiceCallingComponent extends SingleChildCallingComponent {
  ///
  ServiceCallingComponent(
      {required this.rootName,
      required this.child,
      this.serviceMaxIdleDuration = const Duration(minutes: 180),
      this.createStateOnCall = true,
      this.createStateOnInitialize = true,
      required this.unknown,
      required this.root})
      : super(child);

  ///
  final String rootName;

  ///
  final bool createStateOnInitialize;

  ///
  final Duration serviceMaxIdleDuration;

  ///
  final bool createStateOnCall;

  ///
  final Component child;

  ///
  final Endpoint root, unknown;

  /// type belirtilmezse bir üsttekini getirir
  /// type belirtilirse ve bir üstteki o type değilse
  /// üst ağaçtan o servisi bulur
  static T of<T extends ServiceState>(BuildContext context) {
    var serviceBinding = context.owner;
    if (serviceBinding is StatefulBinding &&
        (serviceBinding as StatefulBinding).state is T) {
      return (serviceBinding as StatefulBinding).state as T;
    } else {
      var serviceComponent = context.findAncestorStateOfType<T>();

      if (serviceComponent == null) {
        throw Exception("No $T found of binding tree");
      }
      return serviceComponent;
    }
  }

  @override
  ServiceBinding createBinding() => ServiceBinding(this);

  @override
  Calling createCalling(BuildContext context) =>
      ServiceCalling(binding: context as ServiceBinding);
}

///
class ServiceBinding extends SingleChildCallingBinding with ServiceOwnerMixin {
  ///
  ServiceBinding(ServiceCallingComponent component) : super(component);

  @override
  ServiceCallingComponent get component =>
      super.component as ServiceCallingComponent;

  ///
  late Binding rootEndpoint;

  @override
  void _build() {
    serviceRootName = component.rootName;
    rootEndpoint = component.root.createBinding();
    _unknown = component.unknown.createBinding();
    // _crypto = findAncestorStateOfType<CryptoState>();
    // _dataAccessState = findAncestorStateOfType<DataAccessState>();
    // _socketServiceState = findAncestorStateOfType<SocketServiceState>();
    // _httpServiceState = findAncestorStateOfType<HttpServiceState>();
    // //
    // // _crypto? = this;
    // _dataAccessState?.context._owner = this;
    // _socketServiceState?.context._owner = this;
    //
    // _httpServiceState
    //     ?._attach(this); /*
    // _httpServiceState?.context._owner = this;*/
    //
    // addState(_crypto!);
    // addState(_dataAccessState!);
    // addState(_socketServiceState!);
    // addState(_httpServiceState!);

    // _cryptoServiceKey = _cryptoState?.component.key as GlobalKey<CryptoState>;
    // _dataAccessKey =
    //     _dataAccessState?.component.key as GlobalKey<DataAccessState>;
    // _socketServiceKey =
    //     _socketState?.component.key as GlobalKey<SocketServiceState>;
    // _httpServiceKey =
    //     _httpServiceState?.component.key as GlobalKey<HttpServiceState>;

    _calling = component.createCalling(this);
    _child = component.child.createBinding();

    // print("Single Child Building: comp: ${component.runtimeType}\n"
    //     "_child: $_child\n"
    //     "_childComps: $_child");

    _owner = this;
    _child.attachToParent(this);

    var _ancestor = _parent;
    while (_ancestor != null && _ancestor._owner == null) {
      _ancestor._owner = this;
      _ancestor = _ancestor._parent;
    }
    _child._build();
    rootEndpoint._build();
    _unknown!._build();



    // var _bindings = <PathSegment, Binding>{};
    // for (var element in component.children.entries) {
    //   _bindings[element.key] = element.value.createBinding();
    // }
    // children = _bindings;
    //
    // for (var bind in children.values) {
    //   bind.attachToParent(this, _owner ?? this);
    //   bind._build();
    // }
    //
    // _calling = component.createCalling(this);
    //
    // _childrenBindings = [];
    // for (var element in component.children) {
    //   var _binding = element.createBinding();
    //   _childrenBindings!.add(_binding);
    //
    //   _binding.attachToParent(this, _owner ?? this);
    //   _binding._build();
    // }
  }

  @override
  TreeVisitor<Binding> visitChildren(TreeVisitor<Binding> visitor) {
    visitor(this);
    if (!visitor._stopped) {
      return child.visitChildren(visitor);

      // for (var bind in children.values) {
      //   bind.visitChildren(visitor);
      // }
    }
    return visitor;
    //
    // visitor(this);
    // for (var bind in _childrenBindings ?? <Binding>[]) {
    //   bind.visitChildren(visitor);
    // }
  }

  @override
  TreeVisitor<Calling> callingVisitor(TreeVisitor<Calling> visitor) {
    visitor(calling);
    if (!visitor._stopped) {
      return child.visitCallingChildren(visitor);
      //
      // for (var bind in children.values) {
      //   bind.visitCallingChildren(visitor);
      // }
    }
    return visitor;
  }
}

class ServiceCalling extends Calling {
  ServiceCalling({required ServiceBinding binding}) : super(binding: binding);

  @override
  ServiceBinding get binding => super.binding as ServiceBinding;

  @override
  FutureOr<Message> onCall(Request request) {




    if (request.path.notProcessedValues.isEmpty) {
      return binding.rootEndpoint.call(request);
    } else {
      return binding.child.call(request);
    }
  }
}

///
mixin ServiceOwnerMixin on Binding {
  final Map<GlobalKey, StatefulBinding> _states = {};

  addState(State state) {
    _states[state.component.key as GlobalKey] = state.context;
  }

  late String serviceRootName;
}
