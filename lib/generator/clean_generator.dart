import 'dart:io';
import 'dart:isolate';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

class CleanGenerator {
  final Logger _logger;

  CleanGenerator({Logger? logger}) : _logger = logger ?? Logger();

  Future<void> generate(String featureName, String outputPath) async {
    final progress = _logger.progress('Generating clean architecture folders for $featureName');

    try {
      final packageUri = Uri.parse('package:clean_gen_cli/templates/clean_feature');
      final resolvedUri = await Isolate.resolvePackageUri(packageUri);
      
      if (resolvedUri == null) {
        progress.fail('Could not resolve templates. Make sure the package is correctly installed.');
        return;
      }

      final brickPath = resolvedUri.toFilePath();

      if (!Directory(brickPath).existsSync()) {
        progress.fail('Template not found at $brickPath');
        return;
      }

      final generator = await MasonGenerator.fromBrick(Brick.path(brickPath));
      final target = DirectoryGeneratorTarget(
        Directory(p.join(outputPath, featureName.snakeCase)),
      );

      // We use await to ensure the progress shows until completion
      await generator.generate(
        target,
        vars: {'name': featureName},
      );

      progress.complete('Successfully generated clean architecture folders for $featureName');
    } catch (e) {
      progress.fail('Failed to generate: $e');
      _logger.err(e.toString());
    }
  }
}
