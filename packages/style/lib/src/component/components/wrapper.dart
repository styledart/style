part of '../../style_base.dart';







///
class IfMatchWrapper extends SingleChildCallingComponent {
  ///
  IfMatchWrapper(Component child) : super(child);

  @override
  SingleChildCallingBinding createBinding() => SingleChildCallingBinding(this);

  @override
  Calling createCalling(covariant SingleChildCallingBinding context) =>
      _IfMatchCalling(context);
}

class _IfMatchCalling extends Calling {
  _IfMatchCalling(SingleChildCallingBinding binding) : super(binding);

  @override
  FutureOr<Message> onCall(Request request) {
    // TODO: implement onCall
    throw UnimplementedError();
  }
}