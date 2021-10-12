part of '../../style_base.dart';

///
class ServiceWrapper<B extends _BaseService> extends StatelessComponent {
  ///
  ServiceWrapper({required this.service, required this.child});

  ///
  final B service;
  ///
  final Component child;

  @override
  StatelessBinding createBinding() => _BaseServiceBinding<B>(this);

  @override
  Component build(BuildContext context) {
    return child;
  }
}

abstract class _BaseService {
  late final BuildContext context;

  bool initialized = false;

  // ignore: avoid_positional_boolean_parameters
  FutureOr<bool> init([bool inInterface = true]);

  FutureOr<void> _init() async {
    initialized = await init(false);
    _initializeCompleter.complete(initialized);
  }

  late final Completer<bool> _initializeCompleter = Completer<bool>();

  ///
  Future<bool> ensureInitialize() async {
    return await _initializeCompleter.future;
  }
}

class _BaseServiceBinding<B extends _BaseService>
    extends StatelessBinding {
  _BaseServiceBinding(ServiceWrapper<B> component) : super(component);

  @override
  ServiceWrapper<B> get component => super.component as ServiceWrapper<B>;

  @override
  void _build() {
    component.service.context = this;
    super._build();
    component.service._init();
  }

  @override
  void attachToParent(Binding parent) {
    _owner = parent._owner;
    _parent = parent;
    _exceptionHandler = parent.exceptionHandler.copyWith();
    _setServiceToThisAndParents<B>(component.service);
    print("COM SERVICE: ${component.service}");
    super.attachToParent(parent);
  }

  @override
  TreeVisitor<Calling> visitCallingChildren(TreeVisitor<Calling> visitor) {
    return _child!.visitCallingChildren(visitor);
  }
}
