/// Support for doing something awesome.
///
/// More dartdocs go here.
library style_documentor;

import 'package:build/build.dart';
import 'package:style_documentor/src/documentation.dart';
import 'package:style_documentor/src/generated.dart';

Builder documentationBuilder(BuilderOptions options) =>
    DocumentationBuilder(options);

Builder generateServer(BuilderOptions options) => GenerateServerBuilder();
// TODO: https://www.raywenderlich.com/22180993-flutter-code-generation-getting-started
// Builder sharedDocuementBuilder(BuilderOptions options) => SharedPartBuilder(generators, partId);
