/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE, Version 3 (the "License");
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

part of '../../style_base.dart';

/// Base component for server
///
/// Service is service owner that handle requests, hook states
/// and necessary wrappers.
///
/// Server creates a gateway for handle requests.
/// Server also wraps base services(http,ws,logger etc.).
///
class Server extends StatefulComponent {
  ///
  Server(
      {GlobalKey? key,
      this.httpService,
      this.socketService,
      this.dataAccess,
      this.cryptoService,
      Logger? logger,
      String? rootName,
      this.rootEndpoint,
      this.authorization,
      required this.children,
      this.faviconDirectory,
      Map<Type, ExceptionEndpoint>? defaultExceptionEndpoints})
      : logger = logger ?? DefaultLogger(),
        rootName = rootName ?? 'style_server',
        defaultExceptionEndpoints = defaultExceptionEndpoints ??
            {
              Exception: DefaultExceptionEndpoint<Exception>(),
            },
        super(key: key ?? GlobalKey<ServiceState>.random()) {
    this.defaultExceptionEndpoints[Exception] ??=
        DefaultExceptionEndpoint<Exception>();
  }

  ///
  final Map<Type, ExceptionEndpoint> defaultExceptionEndpoints;

  ///
  final String? faviconDirectory;

  ///
  final String rootName;

  ///
  final Logger logger;

  ///
  final Crypto? cryptoService;

  ///
  final DataAccess? dataAccess;

  ///
  final WebSocketService? socketService;

  ///
  final HttpService? httpService;

  ///
  final Authorization? authorization;

  ///
  final List<Component> children;

  ///
  final Component? rootEndpoint;

  @override
  State<StatefulComponent> createState() => ServiceState();
}

///
class ServiceState extends State<Server> {
  @override
  Component build(BuildContext context) {
    Component result = Gateway(children: [
      if (component.faviconDirectory != null)
        RouteBase('favicon.ico', root: Favicon(component.faviconDirectory!)),
      if (component.rootEndpoint != null)
        RouteBase('*root', root: component.rootEndpoint),
      ...component.children
    ]);

    if (component.httpService != null) {
      result = ServiceWrapper<HttpService>(
          service: component.httpService!, child: result);
    }

    result = ServiceWrapper<Logger>(service: component.logger, child: result);
    if (component.cryptoService != null) {
      result = ServiceWrapper<Crypto>(
          service: component.cryptoService!, child: result);
    }

    if (component.socketService != null) {
      result = ServiceWrapper<WebSocketService>(
          service: component.socketService!, child: result);
    }

    if (component.dataAccess != null) {
      result = ServiceWrapper<DataAccess>(
          service: component.dataAccess!, child: result);
    }

    if (component.authorization != null) {
      result = ServiceWrapper<Authorization>(
          service: component.authorization!, child: result);
    }

    return ServiceCallingComponent(
        rootName: component.rootName,
        child: ExceptionWrapper.fromMap(
            map: component.defaultExceptionEndpoints, child: result));
  }
}

///
class ServiceCallingComponent extends SingleChildCallingComponent {
  ///
  ServiceCallingComponent({
    required this.rootName,
    required super.child,
    super.key,
    this.serviceMaxIdleDuration = const Duration(minutes: 180),
    this.createStateOnCall = true,
    this.createStateOnInitialize = true,
  });

  ///
  final String rootName;

  ///
  final bool createStateOnInitialize;

  ///
  final Duration serviceMaxIdleDuration;

  ///
  final bool createStateOnCall;


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
        throw Exception('No $T found of binding tree');
      }
      return serviceComponent;
    }
  }

  @override
  ServerBinding createBinding() => ServerBinding(this);

  @override
  Calling createCalling(BuildContext context) =>
      ServiceCalling(binding: context as ServerBinding);
}

///
class ServerBinding extends SingleChildCallingBinding with ServiceOwnerMixin {
  ///
  ServerBinding(ServiceCallingComponent component) : super(component);

  @override
  ServiceCallingComponent get component =>
      super.component as ServiceCallingComponent;

  ///
  late Binding rootEndpoint;

  late GatewayCalling _childGateway;

  @override
  void buildBinding() {
    serviceRootName = component.rootName;
    _calling = component.createCalling(this);
    _child = component.child.createBinding();
    _owner = this;
    _child.attachToParent(this);
    var ancestor = _parent;
    while (ancestor != null && ancestor._owner == null) {
      ancestor._owner = this;
      ancestor = ancestor._parent;
    }
    _child.buildBinding();
    _childGateway = _child.visitCallingChildren(TreeVisitor((visitor) {
      if (visitor.currentValue is GatewayCalling) {
        visitor.stop();
      }
    })).result as GatewayCalling;
    executeCronJobs();
  }

  @override
  TreeVisitor<Binding> visitChildren(TreeVisitor<Binding> visitor) {
    if (visitor.stopped) return visitor;
    visitor(this);
    if (!visitor.stopped) {
      return child.visitChildren(visitor);
    }
    return visitor;
  }

  @override
  TreeVisitor<Calling> callingVisitor(TreeVisitor<Calling> visitor) {
    if (visitor.stopped) return visitor;
    visitor(calling);
    if (!visitor.stopped) {
      return child.visitCallingChildren(visitor);
    }
    return visitor;
  }
}

///
class ServiceCalling extends Calling {
  ///
  ServiceCalling({required ServerBinding binding}) : super(binding);

  @override
  ServerBinding get binding => super.binding as ServerBinding;

  @override
  FutureOr<Message> onCall(Request request) {
    request.path
        .resolveFor(binding._childGateway.childrenBinding.keys.toList());
    return (binding.child).findCalling.calling(request);
  }
}

/// Base service owner can be Server or MicroService(soon).
/// Service owner took states and cron jobs. Also took service root name.
mixin ServiceOwnerMixin on Binding {
  final Map<String, GlobalKey> _states = {};

  /// Add states by key
  @protected
  void addState(State state) {
    _states[state.key.key] = state.key;
  }

  /// Service root name used for redirect, connecting microservices and
  /// connecting remote services.
  late String serviceRootName;

  /// cronJobs took Cron Job route and their period.
  final Map<String, CronTimePeriod> cronJobs = {};

  ///
  @protected
  void addCronJob(String route, CronTimePeriod period) {
    cronJobs[route] = period;
  }

  final _cronJobController = CronJobController();

  /// Call first time
  @protected
  void executeCronJobs() {
    if (_cronJobController.runners.isNotEmpty) {
      throw ArgumentError('Call only once executeCronJobs');
    }
    if (cronJobs.isNotEmpty) {
      for (var c in cronJobs.entries) {
        _cronJobController.add(CronJobRunner(
            period: c.value,
            onCall: (d) {
              callCronJob(c.key, d);
            }));
      }
    }
    _cronJobController.start();
  }

  ///
  Future<void> callCronJob(String route, DateTime time) async {
    var res =
        await findCalling.calling(CronJobRequest(time: time, path: route));
    Logger.of(this).info(this, 'cron_job_executed', payload: res.body?.data as Map<String,dynamic>?);
  }
}
