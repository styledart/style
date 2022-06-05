/*
 * Copyright 2021 styledart.dev - Mehmet Yaz
 *
 * Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE, Version 3 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       https://www.gnu.org/licenses/agpl-3.0.en.html
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';

import 'template_generator.dart';
import 'templates/database.dart';
import 'templates/simple.dart';

///
class CreateProjectCommand extends Command {
  ///
  CreateProjectCommand() {
    argParser.addOption("template", abbr: "t", defaultsTo: "simple",
        callback: (v) {
      template = v ?? "simple";
    }, help: "Select Template", allowed: [
      "simple",
      "database",
      "content_deliver",
      "auth"
    ], allowedHelp: {
      "simple": "Simple Server",
      "database": "Simple Server with DataAccess",
      "content_deliver": "Static Content Deliver Server",
      "auth": "Simple Server with Authorization and DataAccess"
    });
  }

  ///
  String template = "simple";

  ///
  late String projectName;

  ///
  late String directory;

  ///
  late String parentDir;

  void run() async {
    if (argResults?.rest.isEmpty ??
        false || (argResults != null && argResults!.rest.length > 1)) {
      throw UsageException(
          "Project Name Need \n"
          "Run \"style create <arguments> <project_name>\"",
          usage);
    }
    projectName = argResults!.rest.first;
    if (projectName.contains("\\")) {
      throw UsageException("use \"/\" as path separator", usage);
    }
    parentDir = Directory.current.path;
    directory = "$parentDir/$projectName";
    if (await Directory(directory).exists()) {
      throw UsageException("$directory is already exists", usage);
    }
    projectName = projectName.split("/").last;
    await Directory(directory).create();

    if (template == "simple") {
      await create(simpleServer);
    } else if (template == "database") {
      await create(databaseServer);
    } else {
      throw UnimplementedError(
          "Only \"simple\" and \"database\" templates are available");
    }
  }

  ///
  Future<void> create(TemplateGenerator template) async {
    print("Directories creating...");
    await createDirectories(template.directories);
    print("Files creating...");
    await addDocuments(template.documents);
    await _format();
  }

  ///
  Future<void> createDirectories(List<String> directories) async {
    for (var dir in directories) {
      await Directory("$directory/$dir").create();
    }
  }

  @override
  String get description => "Create Style Server";

  @override
  String get name => "create";

  Future<void> _format() async {
    print("Pub Get... in $directory");
    var pubGet = await Process.start("dart", ["pub", "get"],
        workingDirectory: directory);
    var pubListener = pubGet.stdout.listen((event) {
      print(utf8.decode(event));
    });

    var pubGetExit = await pubGet.exitCode;
    print("\"dart pub get\" exit with code: $pubGetExit");

    print("Format...");
    var formatPr = await Process.start("dart", ["format", "--fix", projectName],
        workingDirectory: parentDir);

    var formatListener = formatPr.stdout.listen((event) {
      print(utf8.decode(event));
    });

    var formatExit = await formatPr.exitCode;
    print("\"dart format --fix $projectName\" exit with code: $formatExit");

    await pubListener.cancel();
    await formatListener.cancel();
  }

  String _parse(String str) {
    return str.replaceAll("__projectName__", projectName).replaceAll(
        "__dataDir__", "${directory.replaceAll(Platform.pathSeparator, "/")}");
  }

  ///
  Future<void> addDocuments(Map<String, dynamic> sources) async {
    var s = sources.map((key, value) =>
        MapEntry(_parse(key), value is List<int> ? value : _parse(value)));
    var creating = <Future>[];
    for (var source in s.entries) {
      creating.add(_createAndWrite(source));
    }
    await Future.wait(creating);
  }

  Future<void> _createAndWrite(MapEntry<String, dynamic> val) async {
    var _nFile = "$directory/${val.key}";
    var f = File(_nFile);
    await f.create();
    if (val.value is List<int>) {
      await f.writeAsBytes(val.value);
    } else if (val.value is String) {
      await f.writeAsString(val.value);
    } else {
      throw ArgumentError("Map values must be String or Uint8List");
    }
  }
}
