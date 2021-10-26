import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:build/build.dart';
import 'package:style_documentor/src/endpoint_generator.dart';

class GenerateServerBuilder extends Builder {
  @override
  FutureOr<void> build(BuildStep buildStep) async {
    print("STEP OPENED:::::: ${Directory.current}");

    var raw = await buildStep.readAsString(buildStep.inputId);

    var jsonData = json.decode(raw);

    await buildStep.writeAsString(
        buildStep.inputId.changeExtension(".dart"), generateServer(jsonData));
  }

  String generateServer(Map<String, dynamic> json) {
    var sName = toClassName(json["rootName"]);

    GeneratedEndpoint unknown = GeneratedEndpoint.generateFor(json["unknown"]);
    GeneratedEndpoint root = GeneratedEndpoint.generateFor(json["root"]);

    var server = """
import 'dart:async';

import 'package:style/style_dart.dart';

void main() {
  runService($sName());
}

class $sName extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Server(
      rootName: "${json["rootName"]}",
      defaultUnknownEndpoint: ${unknown.isRedirect ? unknown.full : "${unknown.className}()"},
      rootEndpoint: ${root.isRedirect ? root.full : "${root.className}()"},
      children: [
        // TODO: 
      ],
    );
  }
}
${root.isRedirect ? "" : root.full}
${unknown.isRedirect ? "" : unknown.full}
""";

    return server;
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        ".json": [".dart"]
      };
}

///
String toClassName(String name) {
  var _split = name.split("_");
  var str =
      _split.map((e) => "${e[0].toUpperCase()}${e.substring(1)}").join("");
  str = str
      .split("-")
      .map((e) => "${e[0].toUpperCase()}${e.substring(1)}")
      .join("");
  str = str
      .split("-")
      .map((e) => "${e[0].toUpperCase()}${e.substring(1)}")
      .join("");

  str = str
      .split(" ")
      .map((e) => "${e[0].toUpperCase()}${e.substring(1)}")
      .join("");

  return str;
}
