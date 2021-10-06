part of '../../style_base.dart';

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
  late final BuildContext context;

  bool initialize = false;

  FutureOr<void> init();
}

class _BaseServiceStatefulBinding<B extends _BaseService>
    extends StatelessBinding {
  _BaseServiceStatefulBinding(StatelessComponent component) : super(component);

  @override
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
    _owner = parent._owner;
    _parent = parent;
    _unknown = parent._unknown;
    _setServiceToThisAndParents<B>(component.service);
  }

  @override
  TreeVisitor<Calling> visitCallingChildren(TreeVisitor<Calling> visitor) {
    return _child!.visitCallingChildren(visitor);
  }
}
