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
      try {
        await (callQueue.first)
            .call()
            .timeout((binding.component as CallQueue).timeout);
        callQueue.removeFirst();
      } on Exception catch (e) {
        callQueue.removeFirst();
        print("ON 50 $e");
        rethrow;
      }
    }
    isProcess = false;
  }

  @override
  FutureOr<Message> onCall(Request request) async {
    try {
      var completer = Completer<Message>();
      callQueue.addLast(() async {
        try {
          completer.complete(await binding.child.call(request));
        } on Exception catch (e) {
          print("ON 5 $e");
          rethrow;
        }
      });

      Exception? exception;
      await _trigger().then((value) => null).onError((error, stackTrace) {
        print("ON 32 $error");
        exception = error as Exception;
      }).catchError((e) {
        exception = e;
        print("EERRR:");
      });
      if (exception != null) throw exception!;
      return completer.future;
    } on Exception catch (e) {
      print("ON 6 $e");
      rethrow;
    }
  }
}
