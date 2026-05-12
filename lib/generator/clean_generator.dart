import 'dart:io';
import 'dart:isolate';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

class CleanGenerator {
  Future<void> generate(String featureName, String outputPath) async {
    final logger = Logger();
    final progress = logger.progress('Generating clean architecture folders for $featureName');

    try {
      final packageUri = Uri.parse('package:clean_gen_cli/templates/clean_feature');
      final resolvedUri = await Isolate.resolvePackageUri(packageUri);
      
      if (resolvedUri == null) {
        progress.fail('Could not resolve package:clean_gen_cli/templates/clean_feature');
        return;
      }

      final brickPath = resolvedUri.toFilePath();

      if (!Directory(brickPath).existsSync()) {
        // Fallback or handle error
        progress.fail('Brick not found at $brickPath');
        return;
      }

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
      logger.err(e.toString());
    }
  }
}
