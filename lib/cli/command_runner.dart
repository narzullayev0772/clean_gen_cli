import 'package:args/command_runner.dart';
import 'package:clean_gen_cli/cli/commands/init_command.dart';
import 'package:mason/mason.dart';

class CleanGenCommandRunner extends CommandRunner<void> {
  final Logger _logger;

  CleanGenCommandRunner({Logger? logger})
      : _logger = logger ?? Logger(),
        super('clean_gen', 'A CLI tool to generate clean architecture folders.') {
    addCommand(InitCommand(logger: _logger));
  }
}
