part of '../../../style_base.dart';

class _BaseServiceStatefulBinding<
        T extends State<StatefulComponent>>
    extends StatefulBinding {
  _BaseServiceStatefulBinding(StatefulComponent component)
      : super(component);

  @override
  void attachToParent(Binding parent,
      [ServiceOwnerMixin? owner]) {
    if (T is CryptoState) {
      _crypto = state as CryptoState;
    } else if (T is DataAccessState) {
      _dataAccessState = state as DataAccessState;
    } else if (T is SocketServiceState) {
      _socketServiceState = state as SocketServiceState;
    } else if (T is HttpServiceState) {
      _httpServiceState = state as HttpServiceState;
    }
    super.attachToParent(parent, owner);
  }

  @override
  TreeVisitor<Calling> visitCallingChildren(
      TreeVisitor<Calling> visitor) {
    return _child!.visitCallingChildren(visitor);
  }
}
