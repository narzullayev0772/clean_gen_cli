import 'dart:io';
import 'dart:isolate';
import 'package:mason/mason.dart';

abstract class BaseGenerator {
  final Logger logger;

  BaseGenerator({Logger? logger}) : logger = logger ?? Logger();

  Future<void> generate({
    required String brickName,
    required Map<String, dynamic> vars,
    required String targetDirectory,
  }) async {
    final progress = logger.progress('Generating $brickName...');

    try {
      final packageUri = Uri.parse('package:clean_gen_cli/templates/$brickName');
      final resolvedUri = await Isolate.resolvePackageUri(packageUri);

      if (resolvedUri == null) {
        progress.fail('Could not resolve template: $brickName');
        return;
      }

      final brickPath = resolvedUri.toFilePath();
      if (!Directory(brickPath).existsSync()) {
        progress.fail('Template not found at $brickPath');
        return;
      }

      final generator = await MasonGenerator.fromBrick(Brick.path(brickPath));
      final target = DirectoryGeneratorTarget(Directory(targetDirectory));

      await generator.generate(target, vars: vars);

      progress.complete('Successfully generated $brickName in $targetDirectory');
    } catch (e) {
      progress.fail('Failed to generate $brickName: $e');
      logger.err(e.toString());
    }
  }
}
