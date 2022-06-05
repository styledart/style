import 'package:args/command_runner.dart';
import 'src/create.dart';
import 'src/run.dart';

///
CommandRunner get runner {
  return CommandRunner("style", "Style Dart Framework Console Commands")
    ..addCommand(CreateProjectCommand())
    ..addCommand(RunCommand())
  ;
}
