part of '../../../style_base.dart';

class _BaseServiceComponent<B extends _BaseService> extends StatelessComponent {
  _BaseServiceComponent({required this.service, required this.child});

  final B service;
  final Component child;

  @override
  StatelessBinding createBinding() => _BaseServiceStatefulBinding<B>(this);

  @override
  Component build(BuildContext context) {
    return child;
  }
}

abstract class _BaseService {

  late BuildContext context;

  bool initialize = false;

  FutureOr<void> init();
}

class _BaseServiceStatefulBinding<B extends _BaseService>
    extends StatelessBinding {
  _BaseServiceStatefulBinding(StatelessComponent component) : super(component);

  @override
  // TODO: implement component
  _BaseServiceComponent<B> get component =>
      super.component as _BaseServiceComponent<B>;


  @override
  void _build() {
    component.service.context = this;
    component.service.init();
    super._build();
  }

  @override
  void attachToParent(Binding parent) {
    CryptoService? _newCrypt;
    DataAccess? _newDataAccess;
    WebSocketService? _newSocketService;
    HttpServiceHandler? _newHttpService;
    if (B == CryptoService) {
      _newCrypt = component.service as CryptoService;
    } else if (B == DataAccess) {
      _newDataAccess = component.service as DataAccess;
    } else if (B == WebSocketService) {
      _newSocketService = component.service as WebSocketService;
    } else if (B == HttpServiceHandler) {
      _newHttpService = component.service as HttpServiceHandler;
    }
    // print("""Service Attached from : $this
    // crypto: $_crypto,
    // data: $_dataAccess
    // socket: $_socketService
    // http: $_httpService
    // """);
    _owner = parent._owner;
    _parent = parent;
    _unknown = parent._unknown;

    _crypto = _newCrypt ?? parent._crypto;
    _owner?._crypto ??= _crypto;
    _httpService = _newHttpService ?? parent._httpService;
    _owner?._httpService ??= _httpService;
    _socketService = _newSocketService ?? parent._socketService;
    _owner?._socketService ??= _socketService;
    _dataAccess = _newDataAccess ?? parent._dataAccess;
    _owner?._dataAccess ??= _dataAccess;
  }

  @override
  TreeVisitor<Calling> visitCallingChildren(TreeVisitor<Calling> visitor) {
    return _child!.visitCallingChildren(visitor);
  }
}
