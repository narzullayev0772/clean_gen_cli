import 'package:path/path.dart' as p;
import 'package:clean_gen_cli/generator/models/feature_schema.dart';
import 'package:clean_gen_cli/generator/templates/api_service_template.dart';
import 'package:clean_gen_cli/generator/templates/repository_template.dart';
import 'package:clean_gen_cli/generator/utils/file_writer.dart';
import 'package:clean_gen_cli/generator/utils/model_generator.dart';
import 'package:mason/mason.dart';

class DataLayerGenerator {
  final Logger logger;

  DataLayerGenerator({required this.logger});

  Future<void> generate({
    required String basePath,
    required String featureName,
    required List<FunctionDef> functions,
    String modelStrategy = 'empty',
  }) async {
    try {
      final dataPath = p.join(basePath, 'data');

      // Generate API Service
      await _generateApiService(dataPath, featureName, functions);

      // Generate Models
      await _generateModels(dataPath, featureName, functions, modelStrategy);

      // Generate Repository
      await _generateRepository(dataPath, featureName, functions);

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

  Future<void> _generateModels(
    String dataPath,
    String featureName,
    List<FunctionDef> functions,
    String modelStrategy,
  ) async {
    final requestsPath = p.join(dataPath, 'models', 'requests');
    final responsesPath = p.join(dataPath, 'models', 'responses');

    // Generate request and response models for each function
    for (final function in functions) {
      // Generate request model
      if (function.request != null) {
        final requestModel = ModelGenerator.generateRequestModel(function, strategy: modelStrategy);
        if (requestModel.isNotEmpty) {
          final fileName = '${FileWriter.toSnakeCase(function.name)}_request.dart';
          await FileWriter.createDartFile(
            dirPath: requestsPath,
            fileName: fileName,
            content: requestModel,
          );
        }
      }

      // Generate response model
      if (function.response != null) {
        final responseModel = ModelGenerator.generateResponseModel(function, strategy: modelStrategy);
        if (responseModel.isNotEmpty) {
          final fileName = '${FileWriter.toSnakeCase(function.name)}_model.dart';
          await FileWriter.createDartFile(
            dirPath: responsesPath,
            fileName: fileName,
            content: responseModel,
          );
        }
      }
    }
  }

  Future<void> _generateRepository(
    String dataPath,
    String featureName,
    List<FunctionDef> functions,
  ) async {
    final snakeName = FileWriter.toSnakeCase(featureName);


    // Repository implementation
    final implContent = RepositoryImplTemplate.generate(featureName, functions);
    await FileWriter.createDartFile(
      dirPath: p.join(dataPath, 'repositories'),
      fileName: '${snakeName}_repository_impl.dart',
      content: implContent,
    );
  }
}

