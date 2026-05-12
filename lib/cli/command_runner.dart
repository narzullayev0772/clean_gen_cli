import 'package:args/command_runner.dart';
import 'package:clean_gen_cli/cli/commands/clean_gen_command.dart';

class CleanGenCommandRunner extends CommandRunner<void> {
  CleanGenCommandRunner()
      : super('clean_gen', 'A CLI tool to generate clean architecture folders.') {
    addCommand(CleanGenCommand());
  }
}
