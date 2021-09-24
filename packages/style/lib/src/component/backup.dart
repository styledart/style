/// find childState
// State? result;
// void visitor(Binding binding) {
//   if (result == null && binding is StatefulBinding && binding.state is T) {
//     result = binding.state;
//     return;
//   } else {
//     return;
//   }
// }
//
// visitChildren(visitor);
// return result as T?;

/// find child service

// ServiceBinding? result;
// void visitor(Binding binding) {
//   if (result == null && binding is T) {
//     result = binding;
//     return;
//   } else {
//     return;
//   }
// }
//
// // visitChildren(visitor);
// // return result as T?;

/// binding
// void updateComponent(Component old, Component newComponent) {
//   _component = newComponent;
//   _key = newComponent.key ?? getRandomId(10);
//   visitChildren((binding) {
//     ///
//     if (binding is! CallingBinding) {
//       updateChild(binding);
//     } else {
//       return;
//     }
//   });
// }

/// Endpoint calling binding
//
// class EndpointCallingBinding extends CallingBinding {
//   EndpointCallingBinding(EndpointCallingComponent component)
//          : super(component);
//
//   @override
//   EndpointCallingComponent get component =>
//       super.component as EndpointCallingComponent;
//
//   @override
//   void rebuild() {}
//
//   @override
//   Calling get calling => EndpointComponentCalling(this);
//
//   @override
//   Calling createCalling(CallingBinding context) {
//     // TODO: implement createCalling
//     throw UnimplementedError();
//   }
// }



