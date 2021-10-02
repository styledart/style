part of '../../style_base.dart';



///
class CallQueue extends SingleChildCallingComponent {
  ///
  CallQueue(this.child, {this.timeout = const Duration(seconds: 10)})
      : super(child);

  ///
  final Component child;

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

  Queue<Future<void> Function()> callQueue = Queue.from([]);

  @override
  SingleChildCallingBinding get binding =>
      super.binding as SingleChildCallingBinding;

  bool isProcess = false;

  Future<void> _trigger() async {
    if (isProcess) return;
    isProcess = true;
    while (callQueue.isNotEmpty) {
      await (callQueue.removeFirst())
          .call()
          .timeout((binding.component as CallQueue).timeout);
    }
    isProcess = false;
  }

  @override
  FutureOr<Message> onCall(Request request) {
    var completer = Completer<Message>();
    callQueue.addLast(() async {
      completer.complete(await binding.child.call(request));
    });
    _trigger();
    return completer.future;
  }
}



