import 'package:path/path.dart' as p;
import 'package:clean_gen_cli/generator/models/feature_schema.dart';
import 'package:clean_gen_cli/generator/templates/api_service_template.dart';
import 'package:clean_gen_cli/generator/templates/repository_template.dart';
import 'package:clean_gen_cli/generator/utils/file_writer.dart';
import 'package:mason/mason.dart';

class DataLayerGenerator {
  final Logger logger;

  DataLayerGenerator({required this.logger});

  Future<void> generate({
    required String basePath,
    required String featureName,
    required List<FunctionDef> functions,
  }) async {
    try {
      final dataPath = p.join(basePath, 'data');

      // Generate API Service
      await _generateApiService(dataPath, featureName, functions);

      // Generate Models (placeholder)
      await _generateModels(dataPath, featureName);

      // Generate Bodies (placeholder)
      await _generateBodies(dataPath, featureName, functions);

      // Generate Repository
      await _generateRepository(dataPath, featureName);

      logger.info('✓ Data layer generated for $featureName');
    } catch (e) {
      logger.err('Failed to generate data layer: $e');
      rethrow;
    }
  }

  Future<void> _generateApiService(
    String dataPath,
    String featureName,
    List<FunctionDef> functions,
  ) async {
    final snakeName = FileWriter.toSnakeCase(featureName);
    final content = ApiServiceTemplate.generate(featureName, functions);

    await FileWriter.createDartFile(
      dirPath: p.join(dataPath, 'data_sources'),
      fileName: '${snakeName}_api_service.dart',
      content: content,
    );
  }

  Future<void> _generateModels(String dataPath, String featureName) async {
    // Create models directory with placeholder README
    final modelsPath = p.join(dataPath, 'models');

    // Create directory by attempting to create README
    await FileWriter.createDartFile(
      dirPath: modelsPath,
      fileName: '._placeholder',
      content: '// Models go here',
    );
  }

  Future<void> _generateBodies(
    String dataPath,
    String featureName,
    List<FunctionDef> functions,
  ) async {
    // Create bodies directory with placeholder
    final bodiesPath = p.join(dataPath, 'bodies');

    for (final function in functions) {
      final fileName = '${FileWriter.toSnakeCase(function.name)}_body.dart';
      final content = '''// Request/Response body for ${function.name}
// Generated from .arch.json schema

class ${FileWriter.toCamelCase(function.name)}Body {
  // TODO: Define request/response fields
}
''';

      await FileWriter.createDartFile(
        dirPath: bodiesPath,
        fileName: fileName,
        content: content,
      );
    }
  }

  Future<void> _generateRepository(String dataPath, String featureName) async {
    final snakeName = FileWriter.toSnakeCase(featureName);


    // Repository implementation
    final implContent = RepositoryImplTemplate.generate(featureName);
    await FileWriter.createDartFile(
      dirPath: p.join(dataPath, 'repositories'),
      fileName: '${snakeName}_repository_impl.dart',
      content: implContent,
    );
  }
}

