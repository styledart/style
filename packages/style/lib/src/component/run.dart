part of '../style_base.dart';

///
void runService(Component component) {
  var binding = component.createBinding();
  binding._build();


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
  var results = <String>[];
  binding.visitCallingChildren(TreeVisitor((binding) {
    if (binding.currentValue is EndpointCalling) {
      var path =
          (binding.currentValue.binding as EndpointCallingBinding).fullPath;
      if (!path.endsWith("/*root")) {
        results.add("%$path %");
      }
    }
  }));
  print(results.join("\n"));
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