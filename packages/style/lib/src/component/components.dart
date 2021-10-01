part of '../style_base.dart';

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
  final List<Component> children;

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

  late GatewayCalling _childGateway;

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

    // _cryptoServiceKey =
    // _cryptoState?.component.key as GlobalKey<CryptoState>;
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

    _childGateway = _child.visitCallingChildren(TreeVisitor((visitor) {
      if (visitor.currentValue is GatewayCalling) {
        visitor.stop(visitor.currentValue);
      }
    })).result as GatewayCalling;

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
    if (visitor._stopped) return visitor;
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
    if (visitor._stopped) return visitor;
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

///
class ServiceCalling extends Calling {
  ///
  ServiceCalling({required ServiceBinding binding}) : super(binding: binding);

  @override
  ServiceBinding get binding => super.binding as ServiceBinding;

  @override
  FutureOr<Message> onCall(Request request) {
    var n =
        request.path.resolveFor(binding._childGateway.components.keys.toList());

    if (n.segment.isRoot) {
      return (binding.rootEndpoint).call(request);
    } else if (n.segment.isUnknown) {
      return (binding.unknown).call(request);
    } else {
      return (binding.child).call(request);
    }

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

  ///
  void addState(State state) {
    _states[state.component.key as GlobalKey] = state.context;
  }

  ///
  late String serviceRootName;
}

///
class EndpointCalling extends Calling {
  ///
  EndpointCalling(EndpointCallingBinding endpoint) : super(binding: endpoint);

  @override
  // TODO: implement binding
  EndpointCallingBinding get binding => super.binding as EndpointCallingBinding;

  @override
  FutureOr<Message> onCall(Request request) {
    return binding.component.onCall(request);
  }
}

///
abstract class Endpoint extends CallingComponent {
  ///
  Endpoint({Key? key}) : super(key: key);

  ///
  late final BuildContext? _context;

  ///
  BuildContext get context => _context!;

  @override
  CallingBinding createBinding() => EndpointCallingBinding(this);

  @override
  Calling createCalling(BuildContext context) =>
      EndpointCalling(context as EndpointCallingBinding);

  ///
  FutureOr<Message> onCall(Request request);
}

///
class EndpointCallingBinding extends CallingBinding {
  ///
  EndpointCallingBinding(CallingComponent component) : super(component);

  @override
  Endpoint get component => super.component as Endpoint;

  // String get lastPath {
  //
  //   String? path;
  //
  //   List<Component> ancestorComponents = [];
  //   CallingBinding? ancestor;
  //   ancestor = this;
  //
  //   while (ancestor is! ServiceBinding && ancestor != null) {
  //     if (ancestor.component is PathSegmentBindingMixin) {
  //       var n = ((ancestor).component as PathSegmentBindingMixin)
  //                  .segment.name;
  //       if (!(n == "*root" || n == "*unknown")) {
  //         path = n;
  //         break;
  //       }
  //     }
  //     ancestorComponents.add(ancestor.component);
  //     ancestor = ancestor.ancestorCalling;
  //   }
  //
  // }

  ///
  String get fullPath {
    var list = <String>[];
    var ancestorComponents = <Component>[];
    CallingBinding? ancestor;
    ancestor = this;
    while (ancestor is! ServiceBinding && ancestor != null) {
      if (ancestor.component is PathSegmentMixin) {
        list.add(((ancestor).component as PathSegmentMixin).segment.name);
      }
      ancestorComponents.add(ancestor.component);
      ancestor = ancestor.ancestorCalling;
    }
    if (list.isEmpty) {
      throw Exception("No Service Found from: \nFrom:$ancestorComponents");
    }

    list.add(owner.httpService.address);

    return list.reversed.join("/");
  }

  @override
  TreeVisitor<Binding> visitChildren(TreeVisitor<Binding> visitor) {
    if (visitor._stopped) return visitor;
    visitor(this);
    return visitor;
  }

  @override
  void _build() {
    component._context = this;
    _calling = component.createCalling(this);
  }

  @override
  TreeVisitor<Calling> callingVisitor(TreeVisitor<Calling> visitor) {
    if (visitor._stopped) return visitor;
    visitor(calling);
    return visitor;
  }
}

///
abstract class StatefulEndpoint extends StatefulComponent {
  @override
  EndpointState createState();
}

///
abstract class EndpointState<T extends StatefulEndpoint> extends State<T> {
  ///
  FutureOr<Message> onCall(Request request);

  @override
  Component build(BuildContext context) {
    return _EndpointState(onCall);
  }
}

class _EndpointState extends Endpoint {
  _EndpointState(this.call);

  final FutureOr<Message> Function(Request request) call;

  @override
  FutureOr<Message> onCall(Request request) {
    return call(request);
  }
}

///
class UnknownEndpoint extends Endpoint {
  ///
  UnknownEndpoint() : super();

  @override
  FutureOr<Message> onCall(Request request) {
    return request.createJsonResponse({
      "reason": "route_unknown",
      "route": request.context.pathController.current
    });
  }
}

/// Unknown Wrapper set sub-context default [unknown]
///
class UnknownWrapper extends StatelessComponent {
  /// Unknown must one of endpoint in sub-tree
  UnknownWrapper({Key? key, required this.unknown, required this.child})
      : super(key: key);

  ///
  final Component child, unknown;

  @override
  Component build(BuildContext context) {
    return child;
  }

  @override
  StatelessBinding createBinding() {
    return _UnknownWrapperBinding(this);
  }
}

class _UnknownWrapperBinding extends StatelessBinding {
  _UnknownWrapperBinding(UnknownWrapper component) : super(component);

  @override
  void _build() {
    _unknown = component.unknown.createBinding();
    super._build();
  }

  @override
  UnknownWrapper get component => super.component as UnknownWrapper;
}

///
class Gate extends SingleChildCallingComponent {
  ///
  Gate({required Component child, required this.onRequest}) : super(child);

  ///
  FutureOr<Message> Function(Request request) onRequest;

  @override
  SingleChildCallingBinding createBinding() => SingleChildCallingBinding(this);

  @override
  Calling createCalling(BuildContext context) =>
      GateCalling(context as SingleChildCallingBinding);
}

///
class GateCalling extends Calling {
  ///
  GateCalling(SingleChildCallingBinding binding) : super(binding: binding);

  @override
  SingleChildCallingBinding get binding =>
      super.binding as SingleChildCallingBinding;

  @override
  FutureOr<Message> onCall(Request request) async {
    try {
      var gateRes = await (binding.component as Gate).onRequest(request);

      if (gateRes is Response) {
        return gateRes;
      } else {
        return binding.child.call(request);
      }
    } on Exception catch (e) {
      rethrow;
    }
  }
}

///
class AuthFilterGate extends StatelessComponent {
  ///
  const AuthFilterGate(
      {Key? key, required this.child, this.authRequired = true})
      : super(key: key);

  ///
  final Component child;

  /// If false, authorized requests blocked
  final bool authRequired;

  ///
  FutureOr<Message> checkAuth(Request request) {
    //TODO
    if ((authRequired && request.context.accessToken != null) ||
        (!authRequired && request.context.accessToken == null)) {
      return request;
    } else {
      throw Exception(
          authRequired ? "Auth Required" : "Authorized Request not allowed");
    }
  }

  @override
  Component build(BuildContext context) {
    return Gate(child: child, onRequest: checkAuth);
  }
}

///
class SimpleEndpoint extends Endpoint {
  ///
  SimpleEndpoint(this.onRequest);

  ///
  final FutureOr<Message> Function(Request request) onRequest;

  @override
  FutureOr<Message> onCall(Request request) => onRequest(request);
}

///
class Redirect extends Endpoint {
  ///
  Redirect(this.path);

  ///
  final String? path;

  ///
  static FutureOr<Message> redirect(
      {required Request request,
      required String? path,
      required BuildContext context}) async {
    if (path == null) {
      return context.unknown.call(request);
    }

    var uri = Uri.parse(path);

    if (uri.hasScheme) {
      if (uri.scheme.startsWith("http")) {
        if (request is HttpRequest) {
          var uriString = uri.toString();

          var regex = RegExp(r"%7B([^}]*)%7D");

          print("URI: ${uriString}");

          if (regex.hasMatch(uriString)) {
            print("MATCH");
            uriString = uriString.replaceAllMapped(regex, (match) {
              var matched = uriString.substring(match.start, match.end);
              matched = matched.substring(3, matched.length - 3);
              print("MATCHED: ${matched}");
              return request.path.arguments[matched] ?? "null";
            });
          }

          request.baseRequest.response
            ..statusCode = 301
            ..headers.add("Location", uriString)
            ..close();
          return NoResponseRequired(request: request);
        } else {
          var req = await io.HttpClient().getUrl(uri);
          var res = await req.close();
          var resBodyList = await res.toList();
          var resBodyBinary = mergeList(resBodyList as List<Uint8List>);
          var resBody = utf8.decode(resBodyBinary);
          throw "un";
        }
      } else {
        throw "un";
      }
    } else {
      var segments = List<String>.from(uri.pathSegments);

      if (segments.first != "..") {
        var service = context.findAncestorServiceByName(segments.first);
        if (service == null) {
          throw "Service Not Found";
        }
        segments.removeAt(0);
        request.path.notProcessedValues.addAll(segments);
        request.path.current = segments.first;
        return service.call(request);
      }

      var nBinding = context;
      while (segments.first == "..") {
        var n = nBinding.findAncestorBindingOfType<GatewayBinding>();
        if (n == null) {
          throw Exception("Path No Found");
        }
        nBinding = n;
        segments.removeAt(0);
      }
      request.path.notProcessedValues.addAll(segments);
      request.path.current = segments.first;
      return ((nBinding).findAncestorBindingOfType<RouteBinding>() ??
              nBinding.findAncestorBindingOfType<ServiceBinding>()!)
          .call(request);
    }
  }

  @override
  FutureOr<Message> onCall(Request request) {
    return redirect(request: request, path: path, context: context);
  }
}

///
class GeneratedRedirect extends Endpoint {
  ///
  GeneratedRedirect({required this.generate});

  ///
  final Future<String?> Function(Request request) generate;

  @override
  FutureOr<Message> onCall(Request request) async {
    var uri = await generate(request);
    return Redirect.redirect(request: request, path: uri, context: context);
  }
}

///
class AuthRedirect extends StatelessComponent {
  ///
  const AuthRedirect(
      {Key? key, required this.authorized, required this.unauthorized})
      : super(key: key);

  ///
  final String authorized, unauthorized;

  @override
  Component build(BuildContext context) {
    return GeneratedRedirect(generate: (req) async {
      if (req.context.accessToken != null) {
        return authorized;
      } else {
        return unauthorized;
      }
    });
  }
}

///
class SimpleAccessPoint extends StatelessComponent {
  ///
  const SimpleAccessPoint({Key? key}) : super(key: key);

  @override
  Component build(BuildContext context) {
    return AccessPoint((request) {
      var req = (request as HttpRequest);
      return Query(
          selector: (req.path.notProcessedValues.isNotEmpty
              ? req.path.notProcessedValues.first
              : null),
          collection: req.currentPath);
    });
  }
}

/// TODO: Document
class AccessPoint extends Endpoint {
  ///
  AccessPoint(this.dataEq) : super();

  //TODO: Permission

  ///
  final FutureOr<Query> Function(Request request) dataEq;

  @override
  FutureOr<Message> onCall(Request request) async {
    var dataAccess = context.dataAccess;
    var base = (request as HttpRequest).baseRequest;

    if (base.method == "POST") {
      var r = await dataAccess.create(
          await dataEq(request), (request.body as Map).cast<String, dynamic>());
      return request.createJsonResponse(r);
    } else if (base.method == "GET") {
      var r = await dataAccess.read(await dataEq(request));
      return request.createJsonResponse(r);
    } else if (base.method == "PUT" || base.method == "PATCH") {
      var r = await dataAccess.update(
          await dataEq(request), (request.body as Map).cast<String, dynamic>());
      return request.createJsonResponse(r);
    } else if (base.method == "DELETE") {
      var r = await dataAccess.delete(await dataEq(request));
      return request.createJsonResponse(r);
    } else {
      return context.unknown.call(request);
    }
  }
}

///
class DocumentService extends StatefulEndpoint {
  ///
  DocumentService(this.directory, {this.cacheAll = true})
      : assert(directory.endsWith(io.Platform.pathSeparator));

  ///
  final String directory;

  ///
  final bool cacheAll;

  @override
  EndpointState<StatefulEndpoint> createState() =>
      DocumentServiceEndpointState();
}

class DocumentServiceEndpointState extends EndpointState<DocumentService> {
  Map<String, dynamic>? documents;

  Future<void> _loadDirectories() async {
    var docs = <String, io.File>{};

    var entities = <io.FileSystemEntity>[io.Directory(component.directory)];

    while (entities.isNotEmpty) {
      for (var en in List.from(entities)) {
        if (en is io.Directory) {
          entities.addAll(en.listSync());
          print("Dir: $en");
        } else if (en is io.File) {
          var p = en.path
              .replaceFirst(component.directory, "")
              .replaceAll(io.Platform.pathSeparator, "/");
          docs[p] = en;
        }
        entities.removeAt(0);
      }
    }

    print("DOCS : $docs");

    if (component.cacheAll) {
      var cachedDocs = <String, dynamic>{};
      for (var doc in docs.entries) {
        cachedDocs[doc.key] = await (doc.value).readAsString();
      }
      documents = cachedDocs;
    } else {
      documents = docs;
    }
  }

  ///
  late Future<void> loader;

  @override
  void initState() {
    loader = _loadDirectories();
    super.initState();
  }

  @override
  FutureOr<Message> onCall(Request request) async {
    if (documents == null) {
      await loader;
    }

    var not = request.path.notProcessedValues;

    var req = request.path.current +
        (not.isNotEmpty
            ? "${io.Platform.pathSeparator}"
                "${not.join(io.Platform.pathSeparator)}"
            : "");
    var base = (request as HttpRequest).baseRequest;

    if (!documents!.containsKey(req)) {
      base.response.headers.contentType = io.ContentType.html;
      base.response.write("""
      <html>
      <body>
      <h1>404 Not Found</h1>
      <h5>
      Calling: $req
      Only available: ${documents!.keys.toList()}
      </h5>
      </body>
      </html>
      """);
      base.response.close();
    } else {
      if (component.cacheAll) {
        base.response.headers.contentType = io.ContentType.html;
        base.response.write(documents![req]);
        base.response.close();
      } else {
        base.response.headers.contentType = io.ContentType.html;
        base.response.write((documents![req] as io.File).readAsStringSync());
        base.response.close();
      }
    }

    return NoResponseRequired(request: request);
  }
}

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
          visitor.stop(visitor.currentValue);
          return;
        }

        if (visitor.currentValue is RouteCalling) {
          visitor.stop(visitor.currentValue);
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

      _callings[(_childCalling.result! as RouteCalling)
          .binding
          .component
          .segment] = child;
    }

    calling.components = _callings;
  }
}

///
class GatewayCalling extends Calling {
  ///
  GatewayCalling({required CallingBinding binding}) : super(binding: binding);
  // components = {};
  // for (var comp in this.binding.children) {
  //   var seg = (comp as RouteBinding).component.segment;
  //   components[seg] = comp;
  // }

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

/// Adds a new single sub-path or endpoint segment to parent path
///
/// ### [child] to create sub-segments.
/// ### [root] to create endpoint for this segment.
/// ### [unknown] to customize unknown route for this segment
/// and sub-segments.
///
///
/// You can use as split route for sub-segments and this segment.
/// For this use case [child] and [root] both must be defined.
///
///
///
///  * [segment] of ['new_segment'] is adding
///  segment to parent like:
///
/// ```
/// parent/path/new_segment/(...?)
/// ```
///
/// Look [PathSegment] for argument segments.
///
///  * [root] Running when this segment is called as an endpoint.
///  [root] is null responded with [unknown]
///  Next [CallingComponent] from [root] calling in example request:
///
/// ```
/// parent/path/new_segment
/// ```
///
///  * [child] Running when this segments known
///  sub-route is called as an endpoint.
///
/// `parent/path/new_segment/known_route`
///
///  * [unknown] Running when this segments unknown
///  sub-route is called as an endpoint.
///  [unknown] is null responded with first parent [unknown]
///
/// `parent/path/new_segment/any_unknown_route`
///
///
/// # -
///
/// ### Example Dart Code:
/// ```dart
///   /// defined from parent path "host/user"
///   return PathRouter(
///     segment: PathSegment("info"),
///     root: MyUserInfoEndpoint()
///   );
/// ```
/// Added route of `host/user/info` .
/// if request path is `host/user/info` calling next [CallingComponent] from [root].
///
/// ### Detailed
///
/// [Route] component helps to
/// * Adding new single child segments to calling tree
/// * Adding unknown endpoint to this segment
/// * Adding root endpoint to this segment a
class Route extends CallingComponent with PathSegmentMixin {
  /// For argument segments use segment with "{segment}" .
  /// [child], [root] and [unknown]
  Route.withPathSegment(
      {required PathSegment segment,
      Component? child,
      Component? root,
      bool? handleUnknownAsRoot})
      : _segment = segment,
        _root = root,
        _child = child,
        handleUnknownAsRoot = handleUnknownAsRoot ?? false,
        assert(child != null || root != null, "Child or Root must be defined"),
        super();

  /// For argument segments use segment with "{segment}" .
  /// [child], [root] and [unknown] is parent [unknown] in default
  /// for custom [PathSegment] to use constructor [PathRouter.withPathSegment]
  factory Route(String segment,
      {Component? child, Component? root, bool? handleUnknownAsRoot}) {
    return Route.withPathSegment(
        segment: PathSegment(segment),
        child: child,
        root: root,
        handleUnknownAsRoot: handleUnknownAsRoot);
  }

  final PathSegment _segment;

  ///
  final bool handleUnknownAsRoot;

  @override
  PathSegment get segment => _segment;

  @override
  String toString() {
    return "PathRouter(\"${segment.name}\")";
  }

  @override
  Calling createCalling(BuildContext context) =>
      RouteCalling(context as RouteBinding);

  @override
  RouteBinding createBinding() => RouteBinding(this);

  final Component? _root, _child;

  @override
  Component? get root => _root;

  @override
  Component? get child => _child;
}

///
class RouteBinding extends CallingBinding {
  ///
  RouteBinding(Route component) : super(component);

  @override
  void attachToParent(Binding parent) {
    super.attachToParent(parent);
    if (findAncestorBindingOfType<GatewayBinding>() == null) {
      throw UnsupportedError("""
      Incorrect use of parent component
      [Route] working with Gateway.
      But using with: $parent , ${parent.component}
      if you want to only one route use [RouteTo] component
      """);
    }
  }

  ///
  late Binding? childBinding, rootBinding;

  /// Bu segment altındaki available paths
  /// Bu segment user ise
  ///
  /// host/a/user
  /// rootCalling
  /// root u çağırır
  ///
  /// root altında path segment varsa hata verir
  ///
  /// childdaki gateway aranır. Gateway in mümkün olanları buraya eklenir.
  ///
  ///
  GatewayCalling? _childGateway;

  @override
  void _build() {
    _calling = component.createCalling(this);
    rootBinding = component._root?.createBinding();
    childBinding = component._child?.createBinding();

    // if (rootBinding != null && component.handleUnknownAsRoot) {
    //   var unknownBinding = _unknown?.createBinding();
    //   if ((unknownBinding is EndpointCallingBinding) &&
    //       unknownBinding.component._context == null) {
    //     unknownBinding._build();
    //   }
    // }

    // _unknown = component.unknown ?? _unknown;

    childBinding?.attachToParent(
      this,
    );
    rootBinding?.attachToParent(
      this,
    );

    childBinding?._build();
    rootBinding?._build();

    if (rootBinding != null) {
      var _rootGateway =
          rootBinding!.visitCallingChildren(TreeVisitor<Calling>((visitor) {
        if (visitor.currentValue is GatewayCalling) {
          visitor.stop(visitor.currentValue);
          return;
        }
      }));
      assert(
          _rootGateway.result == null,
          "Not push gateway from root"
          "\nwhere: $_errorWhere");
    }

    if (childBinding != null) {
      var childGateway =
          childBinding!.visitCallingChildren(TreeVisitor<Calling>((visitor) {
        if (visitor.currentValue is GatewayCalling) {
          visitor.stop(visitor.currentValue);
          return;
        }
      }));
      if (childGateway.result == null) {
        throw UnsupportedError("""
          if use child, must put gateway the tree
          Route child using for define sub-segments
          
          WHERE: $_errorWhere
          
          """);
      }
      _childGateway = childGateway.result as GatewayCalling;
    }

    ///_unknownBinding.attachToParent(this);
  }

  @override
  TreeVisitor<Calling> callingVisitor(TreeVisitor<Calling> visitor) {
    if (visitor._stopped) return visitor;
    visitor(calling);
    if (component.root != null) {
      rootBinding!.visitCallingChildren(visitor);
    }
    if (component.child != null) {
      childBinding!.visitCallingChildren(visitor);
    }
    // if (component.unknown != null) {
    //   unknownBinding!.visitCallingChildren(visitor);
    // }
    return visitor;
  }

  @override
  TreeVisitor<Binding> visitChildren(TreeVisitor<Binding> visitor) {
    if (visitor._stopped) return visitor;
    visitor(this);

    if (rootBinding != null) {
      rootBinding?.visitChildren(visitor);
    }

    if (childBinding != null) {
      childBinding?.visitChildren(visitor);
    }

    return visitor;
  }

  @override
  Route get component => super.component as Route;
}

/// [RouteCalling] call on request this segment.
/// And route to [child] or [unknown] or [root] which is called
/// as endpoint
class RouteCalling extends Calling {
  /// if child isn't null, creating bindings
  RouteCalling(RouteBinding binding) : super(binding: binding);

  RouteBinding get binding => super.binding as RouteBinding;

  @override
  FutureOr<Message> onCall(Request request) {
    var n = request.path
        .resolveFor(binding._childGateway?.components.keys.toList() ?? []);

    if (n.segment.isRoot) {
      print("N ROOT: ${request.path.current}");
      return (binding.rootBinding ?? binding.unknown).call(request);
    } else if (n.segment.isUnknown) {
      print("N UNK: ${request.path.current}");
      return (binding.component.handleUnknownAsRoot
              ? binding.rootBinding!
              : binding.unknown)
          .call(request);
    } else {
      print("N GATE: ${request.path.current}");
      return (binding._childGateway!.binding).call(request);
    }

    // throw 0;
    //
    // if (n.segment is ArgumentSegment) {
    //   return binding.childBinding!.call(request);
    // } else if (n.segment.isRoot) {
    //   return (binding.rootBinding ?? binding.unknown).call(request);
    // } else {
    //   return (binding.component.handleUnknownAsRoot
    //           ? binding.rootBinding!
    //           : binding.unknown)
    //       .call(request);
    // }
  }
}

/// Each path partition (between "/") is [PathSegment].
///
/// [PathSegment] only use for building call tree.
///
///
/// There is two kind of PathSegment.
/// ```
/// host/{user}/info
/// ```
/// * [NamedSegment] is not handle any parameters.
/// "info" is named segment.
///
///
///
/// * [ArgumentSegment] is handle this segment value
/// and next route if possible.
/// "{user}" is argument segment
///
/// Look [CallingPathSegment] for happening values during the call.
@immutable
abstract class PathSegment {
  /// Automatically create [ArgumentSegment] or [NamedSegment].
  ///
  /// For [ArgumentSegment], name must be starts with ":" or wrapped with "{}"
  factory PathSegment(String name) {
    if (name.startsWith(":") || (name.startsWith("{") && name.endsWith("}"))) {
      String _name;
      if (name.startsWith(":")) {
        _name = name.substring(1, name.length);
      } else {
        _name = name.substring(1, name.length - 1);
      }
      return ArgumentSegment(_name);
    } else {
      return NamedSegment(name);
    }
  }

  const PathSegment._(this.name);

  /// Path Segment Name
  final String name;

  /// Path Segment is unknown.
  /// if isUnknown is true, calling
  /// unknown route of binding
  bool get isUnknown => name == "*unknown";

  /// Is root of parent segment
  ///
  /// if client call `host/user`,
  /// path converting to 'host/user/*root'
  /// for only internal operations
  bool get isRoot => name == "*root";

  @override
  bool operator ==(Object other) =>
      other.runtimeType == runtimeType && (other as PathSegment).name == name;

  @override
  String toString() {
    return name;
  }

  @override
  int get hashCode => Object.hash(name, runtimeType);
}

/// ```
/// host/{user}/info
/// ```
/// * [NamedSegment] is not handle any parameters.
/// "info" is named segment.
class NamedSegment extends PathSegment {
  /// Not use with ":" or "{}"
  const NamedSegment(String name) : super._(name);

  @override
  String toString() {
    return "NamedSegment($name)";
  }
}

/// ```
/// host/{user}/info
/// ```
/// * [ArgumentSegment] is handle this segment value
/// and next route if possible.
/// "{user}" is argument segment
class ArgumentSegment extends PathSegment {
  /// Not use without ":" or "{}"
  const ArgumentSegment(String name) : super._(name);

  @override
  String toString() {
    return "ArgSegment($name)";
  }
}

/// Happening [PathSegment] on during the call
///
/// Carries happening values
abstract class CallingPathSegment {
  /// Don't use
  factory CallingPathSegment(
      {required PathSegment segment, required String value}) {
    if (segment is NamedSegment) {
      return NamedCallingSegment(segment: segment);
    } else {
      return ArgumentCallingSegment(
          value: value, segment: segment as ArgumentSegment);
    }
  }

  /// create unknown path segment
  factory CallingPathSegment.unknown() {
    return CallingPathSegment(
        segment: PathSegment("*unknown"), value: "*unknown");
  }

  const CallingPathSegment._({required this.value, required this.segment});

  /// Takes a segment when the actual and defined segments match.
  final PathSegment segment;

  /// Takes a value when the actual and defined segments match.
  /// Otherwise is segment is unknown or root value is empty.
  ///
  /// in NamedCallingSegment value is segment name
  final String value;

  @override
  String toString() {
    return value;
  }
}

/// Happening [NamedSegment] on during the call
class NamedCallingSegment extends CallingPathSegment {
  ///
  NamedCallingSegment({required NamedSegment segment})
      : super._(segment: segment, value: segment.name);

  @override
  String toString() {
    return "CallingPath($value) match $segment";
  }
}

/// Happening [ArgumentSegment] on during the call
class ArgumentCallingSegment extends CallingPathSegment {
  ///
  const ArgumentCallingSegment(
      {required String value, required ArgumentSegment segment})
      : super._(value: value, segment: segment);

  @override
  String toString() {
    return "CallingPath({$value}) match $segment";
  }
}

/// Each object in the call tree is generated by a [CallingComponent].
/// Some [Calling]s in the tree create a path segment.
mixin PathSegmentMixin on CallingComponent {
  /// This Calling Component segment
  PathSegment get segment;

  /// Using this segment calling as a endpoint
  Component? get root;

  /// Using known child
  Component? get child;
}

/// [PathController] is controller for during the call
/// and visiting call tree callings.
///
class PathController {
  ///
  PathController(this.calledPath)
      : notProcessedValues = calledPath
            .split("/")
            .where((element) => element.isNotEmpty)
            .toList() {
    current = notProcessedValues.isEmpty ? "*root" : notProcessedValues.first;
  }

  /// Called full path
  final String calledPath;

  /// Store path arguments like:
  ///
  /// path : "user/{user_id}/path"
  /// call : "user/user1/path"
  ///
  /// arguments stored key value pair:
  ///
  /// ```
  /// {
  ///   "user_id" : "user1"
  ///   // others
  /// }
  /// ```
  ///
  final Map<String, String> arguments = {};

  /// The processed paths are kept here as the call progresses through the tree.
  final List<CallingPathSegment> processed = [];

  /// First segment to be processed
  late String current;

  /// Next segments to be processed,
  /// include current
  final List<String> notProcessedValues;

  /// Each PathSegmentCalling calls resolveFor for its children.
  /// resolveFor return subsegments that need to be called.
  CallingPathSegment resolveFor(Iterable<PathSegment> segments) {
    CallingPathSegment? result;
    if (notProcessedValues.isEmpty) {
      result =
          CallingPathSegment(segment: PathSegment("*root"), value: "*root");
    } else {
      current = notProcessedValues.first;
      if (segments.contains(PathSegment(current))) {
        var seg = segments.firstWhere((element) => element.name == current);
        result = NamedCallingSegment(segment: seg as NamedSegment);
      } else {
        var argSeg = segments.firstWhere(
            (element) => element.runtimeType == ArgumentSegment, orElse: () {
          return PathSegment("*unknown");
        });

        if (argSeg.isUnknown) {
          result = NamedCallingSegment(segment: NamedSegment("*unknown"));
        } else {
          result = ArgumentCallingSegment(
              value: current, segment: argSeg as ArgumentSegment);

          arguments[argSeg.name] = current;
          current = "{${argSeg.name}}";
        }
      }
      processed.add(result);
      notProcessedValues.removeAt(0);
    }
    return result;
  }
}

///
class RouteTo extends StatelessComponent {
  ///
  RouteTo(this.segment, {this.child, this.handleUnknownAsRoot, this.root});

  ///
  final String segment;

  ///
  final Component? root;

  ///
  final Component? child;

  ///
  final bool? handleUnknownAsRoot;

  @override
  Component build(BuildContext context) {
    return Gateway(children: [
      Route(segment,
          root: root, handleUnknownAsRoot: handleUnknownAsRoot, child: child)
    ]);
  }
}
