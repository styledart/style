part of '../style_base.dart';

///
Binding runService(Component component) {
  try {
    var binding = component.createBinding();
    binding._build();

    // var results = <String>[];
    // binding.visitCallingChildren(TreeVisitor((binding) {
    //   if (binding.currentValue is EndpointCalling) {
    //     var path =
    //         (binding.currentValue.binding as
    //         EndpointCallingBinding).fullPath;
    //     if (!path.endsWith("/*root")) {
    //       results.add("% $path %");
    //     }
    //   }
    // }));
    // print(results.join("\n"));


    stdin.listen((event) {
      print(binding._owner);
      print(utf8.decode(event));
    });
    return binding;
  }
// ignore: avoid_catches_without_on_clauses
  catch (e, s) {
    var trace = Trace.format(s);
    throw Exception("Error: $e \n Stack Trace: \n $trace");
  }

  // parseFile(path: path, featureSet: featureSet)

  //
  // binding.visitChildren(TreeVisitor<Binding>((visitor) {
  //   print("""
  //
  //   comp ${visitor.currentValue.component}
  //   owner ${visitor.currentValue.owner}
  //
  //   """);
  // }));
  //

  //
  //

  // var visiting = binding.visitChildren(TreeVisitor((binding) {
  //
  // }));
  //
  //
  // var service = binding.findChildState<_Sort>();
  //
  //
}
