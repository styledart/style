part of '../../style_base.dart';

///
class CallQueue extends SingleChildCallingComponent {
  ///
  CallQueue(this.child,
      {this.parallel = 1, this.timeout = const Duration(seconds: 10)})
      : super(child);

  ///
  final Component child;

  ///
  final int parallel;

  ///
  final Duration timeout;

  @override
  SingleChildCallingBinding createBinding() => SingleChildCallingBinding(this);

  @override
  Calling createCalling(covariant SingleChildCallingBinding context) =>
      _QueueCalling(context);
}

class _QueueCalling extends Calling {
  _QueueCalling(SingleChildCallingBinding binding) : super(binding);

  late q.Queue queue = q.Queue(
      parallel: (binding.component as CallQueue).parallel,
      timeout: (binding.component as CallQueue).timeout);

  @override
  SingleChildCallingBinding get binding =>
      super.binding as SingleChildCallingBinding;

  @override
  FutureOr<Message> onCall(Request request) async {

      return queue.add(() async => binding.child.findCalling.calling(request));

  }
}
