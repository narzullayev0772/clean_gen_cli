import 'package:args/command_runner.dart';
import 'package:clean_gen_cli/generator/clean_generator.dart';
import 'package:mason/mason.dart';

class CleanGenCommand extends Command<void> {
  final Logger _logger;
  
  @override
  final String name = 'generate';
  @override
  final String description = 'Generates clean architecture folders.';

  CleanGenCommand({Logger? logger}) : _logger = logger ?? Logger() {
    argParser.addOption(
      'output',
      abbr: 'o',
      defaultsTo: 'lib/src/features/',
      help: 'Output path for the generated folders.',
    );
  }

  @override
  Future<void> run() async {
    if (argResults?.rest.isEmpty ?? true) {
      usageException('Please provide a feature name.');
    }

    final featureName = argResults!.rest.first;
    final outputPath = argResults!['output'] as String;

    final generator = CleanGenerator(logger: _logger);
    await generator.generate(featureName, outputPath);
  }
}
