import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';

class DocumentationBuilder implements Builder {
  DocumentationBuilder(this.options);

  BuilderOptions options;

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    // Get the `LibraryElement` for the primary input.
    var entryLib = await buildStep.inputLibrary;
    print("HANDLE STEP ${entryLib.identifier} :");
    // Resolves all libraries reachable from the primary input.
    var resolver = buildStep.resolver;

    var visibleLibraries = await resolver.libraries.length;

    var info = buildStep.inputId.addExtension('.txt');

    var main = entryLib.topLevelElements
        .where((element) => element.name == "main")
        .first as FunctionElement;

    await buildStep.writeAsString(info, '''
      Options: ${options.config}
      Input ID: ${buildStep.inputId}
      Member count: ${entryLib.topLevelElements.length}
      Visible libraries: $visibleLibraries
      Main: ${main.documentationComment}
      Members:
${entryLib.topLevelElements.toList().join("\n")}
''');
  }

  @override
  // TODO: implement buildExtensions
  Map<String, List<String>> get buildExtensions => {
        ".dart": [".dart.txt"]
      };
}
