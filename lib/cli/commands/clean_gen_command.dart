import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

class CleanGenCommand extends Command<void> {
  @override
  final String name = 'generate';
  @override
  final String description = 'Generates clean architecture folders.';

  CleanGenCommand() {
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
      print('Please provide a feature name.');
      return;
    }

    final featureName = argResults!.rest.first;
    final outputPath = argResults!['output'] as String;

    final logger = Logger();
    final progress = logger.progress('Generating clean architecture folders for $featureName');

    try {
      // For now, we use the local brick path. 
      // In a real CLI package, you might want to bundle this or use a fixed location.
      final brickPath = p.join(
        Directory.current.path,
        'lib/templates/clean_feature',
      );

      final generator = await MasonGenerator.fromBrick(Brick.path(brickPath));
      final target = DirectoryGeneratorTarget(
        Directory(p.join(outputPath, featureName.snakeCase)),
      );

      await generator.generate(
        target,
        vars: {'name': featureName},
      );

      progress.complete('Successfully generated clean architecture folders for $featureName');
    } catch (e) {
      progress.fail('Failed to generate folders: $e');
    }
  }
}
