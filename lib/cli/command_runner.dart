import 'package:args/command_runner.dart';
import 'package:clean_gen_cli/cli/commands/create_command.dart';
import 'package:clean_gen_cli/cli/commands/init_command.dart';
import 'package:mason_logger/mason_logger.dart';

class CleanGenCommandRunner extends CommandRunner<void> {
  final Logger _logger;

  CleanGenCommandRunner({Logger? logger})
      : _logger = logger ?? Logger(),
        super('clean_gen', 'A CLI tool to generate clean architecture features from config files.') {
    addCommand(CreateCommand(logger: _logger));
    addCommand(InitCommand(logger: _logger));
  }
}
