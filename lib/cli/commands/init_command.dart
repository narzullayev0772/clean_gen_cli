import 'dart:convert';
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;
import 'package:recase/recase.dart' as recase;

class InitCommand extends Command<void> {
  final Logger _logger;

  @override
  final String name = 'init';
  @override
  final String description = 'Initializes clean architecture folder structure with .arch.json schema.';

  InitCommand({Logger? logger}) : _logger = logger ?? Logger() {
    argParser.addOption(
      'output',
      abbr: 'o',
      defaultsTo: 'lib/src/features/',
      help: 'Output path for the generated feature folders.',
    );
    argParser.addOption(
      'path',
      abbr: 'p',
      help: 'Optional nested path within output (e.g., category/auth)',
    );
  }

  @override
  Future<void> run() async {
    final featureName = argResults?.rest.firstOrNull;
    if (featureName == null || featureName.isEmpty) {
      usageException('Please provide a feature name.');
    }

    final baseOutputPath = argResults!['output'] as String;
    final nestedPath = argResults!['path'] as String?;

    // Construct the full output path
    final fullOutputPath = nestedPath != null
        ? p.join(baseOutputPath, nestedPath, recase.ReCase(featureName).snakeCase)
        : p.join(baseOutputPath, recase.ReCase(featureName).snakeCase);

    await _createArchitecture(featureName, fullOutputPath);
  }

  Future<void> _createArchitecture(String featureName, String basePath) async {
    final progress = _logger.progress('Initializing clean architecture for $featureName...');

    try {
      // Create directory if it doesn't exist
      final baseDir = Directory(basePath);
      if (!baseDir.existsSync()) {
        baseDir.createSync(recursive: true);
      }

      // Define folder structure
      final folders = [
        'data/datasources',
        'data/models',
        'data/repositories',
        'domain/entities',
        'domain/repositories',
        'domain/usecases',
        'presentation/cubit',
        'presentation/pages',
        'presentation/widgets',
        'di',
      ];

      // Create all folders
      for (final folder in folders) {
        final folderPath = p.join(basePath, folder);
        Directory(folderPath).createSync(recursive: true);
      }

      // Create .arch.json metadata file
      await _createArchJsonMetadata(basePath, featureName);

      // Create .gitkeep files to ensure folders are tracked by git
      for (final folder in folders) {
        final gitkeepPath = p.join(basePath, folder, '.gitkeep');
        await File(gitkeepPath).create(recursive: true);
      }

      progress.complete(
        'Successfully initialized clean architecture at $basePath\n'
        '  Created: ${folders.length} directories\n'
        '  Schema: .arch.json',
      );
    } catch (e) {
      progress.fail('Failed to initialize architecture: $e');
      _logger.err(e.toString());
      rethrow;
    }
  }

  Future<void> _createArchJsonMetadata(String basePath, String featureName) async {
    final metadata = {
      'name': featureName,
      'functions': <Map<String, dynamic>>[],
    };

    final archJsonPath = p.join(basePath, '.arch.json');
    await File(archJsonPath).writeAsString(
      const JsonEncoder.withIndent('  ').convert(metadata),
      flush: true,
    );
  }
}

