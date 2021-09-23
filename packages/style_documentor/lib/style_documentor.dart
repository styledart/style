/// Support for doing something awesome.
///
/// More dartdocs go here.
library style_documentor;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:style_documentor/src/documentation.dart';

Builder documentationBuilder(BuilderOptions options) => DocumentationBuilder(options);

// TODO: https://www.raywenderlich.com/22180993-flutter-code-generation-getting-started
// Builder sharedDocuementBuilder(BuilderOptions options) => SharedPartBuilder(generators, partId);

