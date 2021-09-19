part of 'run.dart';




/// İşlem Çağrısı
///
/// Çağrı bindingler üzerinde gezinir.
///
/// Kimi zaman eş zamanlı olarak bindinge yüklenir
///
/// Kimi zaman kuyruk olarak
///
abstract class Calling {
  Calling({
    required CallingBinding binding,
    /*required this.name*/
  }) : _binding = binding;

  final CallingBinding _binding;

  // String name;

  FutureOr<void> onCall(StyleRequest request);

  int callCount = 0;

  CallingBinding get binding => _binding;
}

