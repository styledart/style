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

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:args/command_runner.dart';

///
class RunCommand extends Command<void> {
  ///
  RunCommand();

  @override
  String get description => 'Run Style Server or Microservice';

  @override
  String get name => 'run';

  @override
  String get invocation => '${runner?.executableName} $name <file>';

  @override
  Future<void> run() async {
    if (argResults == null) {
      usageException('no arguments found');
    }
    var res = argResults!;

    if (res.rest.isEmpty) {
      usageException('File path/name not found');
    }

    var workingDir = Directory.current;
    var fileArg = res.rest.first;
    var fileUri = workingDir.uri.resolve(fileArg);

    var fileParts = fileUri.pathSegments.last.split('.');
    if (fileParts.length < 2) usageException('Dart File not found');
    if (fileParts.last != 'dart') usageException('File is not .dart file');

    var file = File(fileUri.path.replaceFirst('/', ''));

    print(file.path);

    if (!file.existsSync()) usageException('File not found');
    listenStdin();
    receivePort = ReceivePort();

    var package = fileUri.resolve('../.dart_tool/package_config.json');

    print(Platform.resolvedExecutable);

    isolate = await Isolate.spawnUri(
        fileUri, ['arg1', 'arg2', 'arg3'], receivePort.sendPort,
        packageConfig: package);

    // Timer.periodic(Duration(seconds: 1), (timer) {
    //   receivePort.sendPort.send('message');
    // });

    listenReceivePort();
  }

  ///
  void listenReceivePort() {
    receivePort.listen((m) {
      print("receive : $m");
    });
  }

  ///
  void listenStdin() {
    stdin.listen((event) {
      var input = utf8.decode(event);
      print('input: $input');
      if (input.trim().toLowerCase() == 'q') {
        isolate.kill();
        exit(1);
      }
    });
  }

  ///
  late ReceivePort receivePort;

  ///
  late Isolate isolate;
}
