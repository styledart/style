part of '../style_base.dart';

/// Ana Mimarideki her bir parça
///
@immutable
abstract class Component {
  const Component({this.key});

  final Key? key;

  Binding createBinding();

  String toStringDeep() {
    // TODO: implement toStringDeep
    throw UnimplementedError();
  }

  String toStringSort() {
    // TODO: implement toStringSort
    throw UnimplementedError();
  }
}

abstract class StatelessComponent extends Component {
  const StatelessComponent({Key? key}) : super(key: key);

  @override
  StatelessBinding createBinding() =>
      StatelessBinding(this);

  Component build(BuildContext context);

  @override
  String toStringDeep() {
    // TODO: implement toStringDeep
    throw UnimplementedError();
  }

  @override
  String toStringSort() {
    // TODO: implement toStringSort
    throw UnimplementedError();
  }
}

abstract class StatefulComponent extends Component {
  const StatefulComponent({Key? key}) : super(key: key);

  State<StatefulComponent> createState();

  ///
  @override
  StatefulBinding createBinding() => StatefulBinding(this);
}

abstract class State<T extends StatefulComponent> {
  bool get mounted => _binding != null;

  Component build(BuildContext context);

  T? _component;

  ///
  T get component => _component!;

  StatefulBinding? _binding;

  ///
  StatefulBinding get context => _binding!;

  void initState() async {}
}



class Key {
  Key(this.key);

  Key.random() : key = getRandomId(20);
  String key;
}

class GlobalKey<T extends State<StatefulComponent>>
    extends Key {
  GlobalKey(String key) : super(key);

  GlobalKey.random() : super.random();
  StatefulBinding? binding;

  T get currentState {
    assert(binding != null);
    return binding!.state as T;
  }

  bool get mounted =>
      binding != null && binding!._state != null;

  @override
  bool operator ==(Object other) {
    return other is GlobalKey<T> && other.key == key;
  }

  int? _hashCode;

  @override
  int get hashCode => _hashCode ??= Object.hash(key, T);
}

// class EndpointComponentCalling extends Calling {
//   EndpointComponentCalling(EndpointCallingBinding binding)
//       : _binding = binding,
//         super(binding);
//
//   EndpointCallingBinding _binding;
//
//   @override
//   EndpointCallingBinding get binding => _binding;
//
//   @override
//   FutureOr<void> onCall(StyleRequest request) {
//     return binding.component.onCall(request);
//   }
//
//   @override
//   void detach(Binding newBinding) {
//     assert(newBinding is EndpointCallingBinding);
//     _binding = newBinding as EndpointCallingBinding;
//   }
// }
//
// class DevelopmentCalling extends Calling {
//   DevelopmentCalling(DevelopmentBinding binding)
//       : _binding = binding,
//         super(binding);
//
//   DevelopmentBinding _binding;
//
//   @override
//   DevelopmentBinding get binding => _binding;
//
//   @override
//   FutureOr<void> onCall(StyleRequest request) =>
//       binding._child!.calling.onCall(request);
//
//   @override
//   void detach(Binding newBinding) {
//     assert(newBinding is DevelopmentBinding);
//     _binding = newBinding as DevelopmentBinding;
//   }
// }
