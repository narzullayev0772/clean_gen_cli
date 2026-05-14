import 'package:args/command_runner.dart';
import 'package:clean_gen_cli/cli/commands/create_command.dart';
import 'package:clean_gen_cli/cli/commands/init_command.dart';
import 'package:clean_gen_cli/cli/commands/update_command.dart';
import 'package:clean_gen_cli/cli/commands/version_command.dart';
import 'package:mason_logger/mason_logger.dart';

/// The command runner for the Clean Gen CLI.
///
/// It coordinates all the available commands like `create`, `update`, `init`, and `version`.
class CleanGenCommandRunner extends CommandRunner<void> {
  final Logger _logger;

  /// Creates a new [CleanGenCommandRunner].
  CleanGenCommandRunner({Logger? logger})
    : _logger = logger ?? Logger(),
      super(
        'clean_gen',
        'A CLI tool to generate clean architecture features from config files.',
      ) {
    // Global short flag for printing version (-v / --version)
    argParser.addFlag(
      'version',
      abbr: 'v',
      negatable: false,
      help: 'Print package version and exit.',
    );

    addCommand(CreateCommand(logger: _logger));
    addCommand(UpdateCommand(logger: _logger));
    addCommand(InitCommand(logger: _logger));
    addCommand(VersionCommand(logger: _logger));
  }
}
