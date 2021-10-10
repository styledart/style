part of '../style_base.dart';

/// İşlem Çağrısı
///
/// Çağrı bindingler üzerinde gezinir.
///
/// Kimi zaman eş zamanlı olarak bindinge yüklenir
///
/// Kimi zaman kuyruk olarak
///
abstract class Calling {
  ///
  Calling(
    CallingBinding binding,
  ) : _binding = binding;
  final CallingBinding _binding;

  ///
  @internal
  @protected
  FutureOr<Message> onCall(Request request);

  ///
  FutureOr<Message> call(Request request) async {
    try {
      var r = await onCall(request);
      return r;
    } on Exception catch (e, s) {
      return _binding.exceptionHandler
          .getBinding(e)
          .calling
          .onCall(request, e, s);
    }
  }

  ///
  int callCount = 0;

  ///
  CallingBinding get binding => _binding;
}
