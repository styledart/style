part of '../run.dart';

class Server extends StatefulComponent {
  Server(
      {GlobalKey? key,
      HttpServiceHandler? httpServiceNew,
      SocketServiceHandler? socketService,
      DataAccessHandler? dataAccess,
      CryptoHandler? cryptoService,
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
  final String rootName;
  final CryptoHandler cryptoService;
  final DataAccessHandler dataAccess;
  final SocketServiceHandler socketService;
  final HttpServiceHandler httpServiceNew;
  final Map<String, Component> children;
  final Endpoint unknown;
  final Endpoint rootEndpoint;

  Endpoint? get defaultUnknownEndpoint => unknown;

  @override
  State<StatefulComponent> createState() => ServiceState();
}

class ServiceState extends State<Server> {
  String get rootName => component.rootName;

  CryptoHandler get cryptoService => component.cryptoService;

  DataAccessHandler get dataAccess => component.dataAccess;

  SocketServiceHandler get socketService => component.socketService;

  HttpServiceHandler get httpServiceNew => component.httpServiceNew;

  @override
  Component build(BuildContext context) {
    final Map<PathSegment, CallingComponent> _components = component.children
        .map((key, value) => MapEntry(PathSegment(key),
            PathRouter(segment: PathSegment(key), child: value)));

    assert(() {
      var argCount = 0;
      for (var seg in _components.entries) {
        if (seg.key is ArgumentSegment) {
          argCount++;
        }
      }
      return argCount < 2;
    }(), "Gateway Allow only 1 argument segment");
    return DataAccess(
      key: GlobalKey<DataAccessState>.random(),
      dataAccessHandler: dataAccess,
      child: SocketService(
        key: GlobalKey<SocketServiceState>.random(),
        socketServiceHandler: socketService,
        child: HttpService(
            key: GlobalKey<HttpServiceState>.random(),
            httpServiceHandler: httpServiceNew,
            child: CryptoComponent(
                key: GlobalKey<CryptoState>.random(),
                cryptoHandler: cryptoService,
                child: ServiceCallingComponent(
                    httpServiceNew: httpServiceNew,
                    socketService: socketService,
                    dataAccess: dataAccess,
                    cryptoService: cryptoService,
                    rootName: rootName,
                    children: _components))),
      ),
    );
  }
}

class ServiceCallingComponent extends CallingComponent {
  ServiceCallingComponent({
    required this.httpServiceNew,
    required this.socketService,
    required this.dataAccess,
    required this.cryptoService,
    required this.rootName,
    required this.children,
    this.serviceMaxIdleDuration = const Duration(minutes: 180),
    this.createStateOnCall = true,
    this.createStateOnInitialize = true,
  }) : super();

  final String rootName;
  final CryptoHandler cryptoService;
  final DataAccessHandler dataAccess;
  final SocketServiceHandler socketService;
  final HttpServiceHandler httpServiceNew;
  final bool createStateOnInitialize;
  final Duration serviceMaxIdleDuration;
  final bool createStateOnCall;
  final Map<PathSegment, CallingComponent> children;

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

class ServiceBinding extends CallingBinding with ServiceOwnerMixin {
  ServiceBinding(ServiceCallingComponent component) : super(component);

  @override
  ServiceCallingComponent get component =>
      super.component as ServiceCallingComponent;

  late List<Binding> children;

  @override
  void _build() {
    serviceRootName = component.rootName;

    _crypto = findAncestorStateOfType<CryptoState>();
    _dataAccessState = findAncestorStateOfType<DataAccessState>();
    _socketServiceState = findAncestorStateOfType<SocketServiceState>();
    _httpServiceState = findAncestorStateOfType<HttpServiceState>();

    addState(_crypto!);
    addState(_dataAccessState!);
    addState(_socketServiceState!);
    addState(_httpServiceState!);

    // _cryptoServiceKey = _cryptoState?.component.key as GlobalKey<CryptoState>;
    // _dataAccessKey =
    //     _dataAccessState?.component.key as GlobalKey<DataAccessState>;
    // _socketServiceKey =
    //     _socketState?.component.key as GlobalKey<SocketServiceState>;
    // _httpServiceKey =
    //     _httpServiceState?.component.key as GlobalKey<HttpServiceState>;

    _calling = component.createCalling(this);

    var _bindings = <Binding>[];
    for (var element in component.children.values) {
      _bindings.add(element.createBinding());
    }
    children = _bindings;

    for (var bind in children) {
      bind.attachToParent(this, _owner ?? this);
      bind._build();
    }
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

  // @override
  // TreeVisitor<Binding> visitChildren(TreeVisitor<Binding> visitor) {
  //   visitor(this);
  //   if (!visitor._stopped) {
  //     for (var bind in _childrenBindings ?? <Binding>[]) {
  //       bind.visitChildren(visitor);
  //     }
  //   }
  //   return visitor;
  //   //
  //   // visitor(this);
  //   // for (var bind in _childrenBindings ?? <Binding>[]) {
  //   //   bind.visitChildren(visitor);
  //   // }
  // }

  @override
  TreeVisitor<Calling> callingVisitor(TreeVisitor<Calling> visitor) {
    visitor(calling);
    if (!visitor._stopped) {
      for (var bind in children) {
        bind.visitCallingChildren(visitor);
      }
    }
    return visitor;

    // TODO: implement callingVisitor
    throw UnimplementedError();
  }
}

class ServiceCalling extends Calling {
  ServiceCalling({required ServiceBinding binding}) : super(binding: binding);

  @override
  ServiceBinding get binding => super.binding as ServiceBinding;

  @override
  FutureOr<void> onCall(StyleRequest request) {
    // TODO: implement onCall
    throw UnimplementedError();
  }
}

mixin ServiceOwnerMixin on Binding {
  final Map<GlobalKey, StatefulBinding> _states = {};

  addState(State state) {
    _states[state.component.key as GlobalKey] = state.context;
  }

  late String serviceRootName;

  late GlobalKey<DataAccessState> _dataAccessKey;

  late GlobalKey<SocketServiceState> _socketServiceKey;

  late GlobalKey<HttpServiceState> _httpServiceKey;

  late GlobalKey<CryptoState> _cryptoServiceKey;
}
