import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:clean_gen_cli/version.dart';

class VersionCommand extends Command<void> {
  final Logger _logger;

  @override
  final String name = 'version';
  @override
  final String description = 'Prints the current package version.';

  VersionCommand({Logger? logger}) : _logger = logger ?? Logger();

  @override
  Future<void> run() async {
    _logger.info('clean_gen_cli $packageVersion');
  }
}

