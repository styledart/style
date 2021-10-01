import 'dart:io';

import 'package:args/command_runner.dart';

void main(List<String> args) {
  var runner = CommandRunner("style_cli", "Style App Runner");

  runner.argParser.addFlag("flag1", help: "HELP!!!");

  runner.argParser.addFlag("flag2", help: "Help For flag2");

  runner.argParser.addOption("opt2", help: "Help For opt2");

  runner.addCommand(CommitCommand());

  runner.run(args).catchError((error) {
    if (error is! UsageException) throw error;
    print(error);
    exit(64); // Exit code 64 indicates a usage error.
  });
}

class CommitCommand extends Command {
  CommitCommand() {
    argParser.addFlag('all', abbr: 'a',help: "include all");
  }

  ///
  @override
  void run() {
    print(argResults?['all']);
  }

  @override
  String get description => "change data";

  @override
  String get name => "commit";
}
