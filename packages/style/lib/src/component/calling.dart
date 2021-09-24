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
  Calling({
    required CallingBinding binding,
    /*required this.name*/
  }) : _binding = binding;

  final CallingBinding _binding;

  // String name;

  ///
  FutureOr<Message> onCall(Request request);




  ///
  int callCount = 0;

  ///
  CallingBinding get binding => _binding;
}

