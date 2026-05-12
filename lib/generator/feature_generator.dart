import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:clean_gen_cli/generator/layers/data_layer_generator.dart';
import 'package:clean_gen_cli/generator/layers/domain_layer_generator.dart';
import 'package:clean_gen_cli/generator/layers/presentation_layer_generator.dart';
import 'package:clean_gen_cli/generator/models/feature_schema.dart';
import 'package:clean_gen_cli/generator/templates/di_template.dart';
import 'package:clean_gen_cli/generator/utils/file_writer.dart';
import 'package:mason/mason.dart';

/// Main orchestrator for feature generation
/// Coordinates the generation of all layers and files
class FeatureGenerator {
  final Logger logger;
  late final DataLayerGenerator _dataLayer;
  late final DomainLayerGenerator _domainLayer;
  late final PresentationLayerGenerator _presentationLayer;

  FeatureGenerator({required this.logger}) {
    _dataLayer = DataLayerGenerator(logger: logger);
    _domainLayer = DomainLayerGenerator(logger: logger);
    _presentationLayer = PresentationLayerGenerator(logger: logger);
  }

  /// Generate complete feature from schema
  Future<void> generate({
    required String basePath,
    required FeatureSchema schema,
  }) async {
    final timer = Stopwatch()..start();

    try {
      _validatePath(basePath);
      schema.functions.forEach(_validateFunction);

      logger.info('Generating feature: ${schema.name}');

      // Generate all layers
      await _dataLayer.generate(
        basePath: basePath,
        featureName: schema.name,
        functions: schema.functions,
      );

      await _domainLayer.generate(
        basePath: basePath,
        featureName: schema.name,
        functions: schema.functions,
      );

      await _presentationLayer.generate(
        basePath: basePath,
        featureName: schema.name,
        functions: schema.functions,
      );

      // Generate DI file
      await _generateDI(basePath, schema.name, schema.functions);

      // Format generated code
      await _formatGeneratedCode(basePath);

      // Run build_runner
      await _runBuildRunner(basePath);

      timer.stop();
      logger.success(
        '✓ Feature generated successfully (${timer.elapsedMilliseconds}ms)',
      );
    } catch (e) {
      logger.err('Feature generation failed: $e');
      rethrow;
    }
  }

  void _validatePath(String basePath) {
    final dir = Directory(basePath);
    if (!dir.existsSync()) {
      throw Exception('Feature directory not found: $basePath');
    }
  }

  void _validateFunction(FunctionDef function) {
    if (!function.isValid()) {
      throw Exception(
        'Invalid function: ${function.name}. '
        'Required fields: name, api',
      );
    }
  }

  Future<void> _generateDI(
    String basePath,
    String featureName,
    List<FunctionDef> functions,
  ) async {
    final snakeName = FileWriter.toSnakeCase(featureName);
    final diFileName = '${snakeName}_di.dart';

    final content = DITemplate.generate(featureName, functions);

    await FileWriter.createDartFile(
      dirPath: basePath,
      fileName: diFileName,
      content: content,
    );

    logger.info('✓ DI file generated: $diFileName');
  }

  Future<void> _formatGeneratedCode(String basePath) async {
    final progress = logger.progress('Formatting code...');
    try {
      final result = await Process.run('dart', ['format', basePath]);
      if (result.exitCode == 0) {
        progress.complete('Code formatted');
      } else {
        progress.fail('Failed to format code: ${result.stderr}');
      }
    } catch (e) {
      progress.fail('Failed to run dart format: $e');
    }
  }

  Future<void> _runBuildRunner(String basePath) async {
    final projectRoot = _findProjectRoot(basePath);
    if (projectRoot == null) {
      logger.warn('Could not find project root (pubspec.yaml). Skipping build_runner.');
      return;
    }

    final pubspecFile = File(p.join(projectRoot, 'pubspec.yaml'));
    final pubspecContent = await pubspecFile.readAsString();
    if (!pubspecContent.contains('build_runner')) {
      logger.warn('build_runner not found in pubspec.yaml. Skipping generation.');
      return;
    }

    final progress = logger.progress('Running build_runner...');
    try {
      final result = await Process.run(
        'dart',
        ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
        workingDirectory: projectRoot,
      );

      if (result.exitCode == 0) {
        progress.complete('Build runner completed');
      } else {
        progress.fail('Build runner failed: ${result.stderr}');
      }
    } catch (e) {
      progress.fail('Failed to run build_runner: $e');
    }
  }

  String? _findProjectRoot(String startPath) {
    var current = Directory(startPath);
    while (true) {
      final pubspec = File(p.join(current.path, 'pubspec.yaml'));
      if (pubspec.existsSync()) {
        return current.path;
      }
      final parent = current.parent;
      if (parent.path == current.path) break;
      current = parent;
    }
    return null;
  }
}

