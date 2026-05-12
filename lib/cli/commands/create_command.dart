import 'package:args/command_runner.dart';
import 'package:clean_gen_cli/generator/clean_generator.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

class CreateCommand extends Command<void> {
  final Logger _logger;

  @override
  final String name = 'create';
  @override
  final String description = 'Generates clean architecture files (DI, Bloc, UseCase).';

  CreateCommand({Logger? logger}) : _logger = logger ?? Logger() {
    argParser.addOption(
      'output',
      abbr: 'o',
      defaultsTo: 'lib/src/features/',
      help: 'Output path for the generated files.',
    );
    argParser.addFlag(
      'cubit',
      help: 'Generate Cubit instead of Bloc.',
      defaultsTo: false,
    );
  }

  @override
  Future<void> run() async {
    if (argResults?.rest.isEmpty ?? true) {
      usageException('Please provide a feature name.');
    }

    final input = argResults!.rest.first;
    final baseOutputPath = argResults!['output'] as String;
    final useCubit = argResults!['cubit'] as bool;

    // Handle nested paths in feature name (e.g., apps/warehouse/transfer)
    final featureName = p.basename(input);
    final relativePath = p.dirname(input);
    
    final outputPath = relativePath == '.' 
        ? baseOutputPath 
        : p.join(baseOutputPath, relativePath);

    final generator = CleanGenerator(logger: _logger);
    
    // Generate the complete feature structure and files
    await generator.generateFullFeature(
      featureName,
      outputPath,
      useCubit: useCubit,
    );
  }
}
