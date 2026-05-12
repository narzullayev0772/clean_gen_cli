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

    // Check if .arch.json exists
    final archFile = File(p.join(basePath, '.arch.json'));
    if (!archFile.existsSync()) {
      throw Exception('.arch.json not found in feature directory');
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
}

