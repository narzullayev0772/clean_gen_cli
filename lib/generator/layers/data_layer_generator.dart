import 'dart:io';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;
import 'package:clean_gen_cli/generator/models/feature_schema.dart';
import 'package:clean_gen_cli/generator/templates/api_service_template.dart';
import 'package:clean_gen_cli/generator/templates/repository_template.dart';
import 'package:clean_gen_cli/generator/utils/file_writer.dart';
import 'package:clean_gen_cli/generator/utils/model_generator.dart';

class DataLayerGenerator {
  final Logger logger;

  DataLayerGenerator({required this.logger});

  Future<void> generate({
    required String basePath,
    required FeatureSchema schema,
    String modelStrategy = 'empty',
    bool updateOnly = false,
  }) async {
    try {
      final dataPath = p.join(basePath, 'data');

      // Generate API Service
      await _generateApiService(dataPath, schema, updateOnly);

      // Generate Models
      await _generateModels(dataPath, schema, modelStrategy, updateOnly);

      // Generate Repository
      await _generateRepository(dataPath, schema, updateOnly);

      logger.info(
        '✓ Data layer ${updateOnly ? 'updated' : 'generated'} for ${schema.name}',
      );
    } catch (e) {
      logger.err('Failed to generate data layer: $e');
      rethrow;
    }
  }

  Future<void> _generateApiService(
    String dataPath,
    FeatureSchema schema,
    bool updateOnly,
  ) async {
    final snakeName = FileWriter.toSnakeCase(schema.name);
    final dataSourcePath = p.join(dataPath, 'data_sources');
    final fileName = '${snakeName}_api_service.dart';
    final filePath = p.join(dataSourcePath, fileName);

    if (updateOnly && File(filePath).existsSync()) {
      final existingContent = await File(filePath).readAsString();
      for (final function in schema.functions) {
        if (!existingContent.contains('${function.name}(')) {
          // Inject URL constant
          final newConst = ApiServiceTemplate.generateUrlConstant(function);
          await FileWriter.injectToClass(
            filePath: filePath,
            newContent: newConst,
            anchor: '/// Request Methods',
          );

          // Inject Request Method
          final newMethod = ApiServiceTemplate.generateRequestMethod(function);
          await FileWriter.injectToClass(
            filePath: filePath,
            newContent: newMethod,
          );

          // Inject Imports
          final imports =
              ApiServiceTemplate.generateSingleFunctionModelImports(function);
          for (final imp in imports) {
            await FileWriter.injectTopLevel(filePath: filePath, newContent: imp);
          }
        }
      }
    } else {
      final content = ApiServiceTemplate.generate(schema);
      await FileWriter.createDartFile(
        dirPath: dataSourcePath,
        fileName: fileName,
        content: content,
      );
    }
  }

  Future<void> _generateModels(
    String dataPath,
    FeatureSchema schema,
    String modelStrategy,
    bool updateOnly,
  ) async {
    final requestsPath = p.join(dataPath, 'models', 'requests');
    final responsesPath = p.join(dataPath, 'models', 'responses');

    // Generate request and response models for each function
    for (final function in schema.functions) {
      // Generate request model
      if (function.request != null) {
        final fileName = '${FileWriter.toSnakeCase(function.name)}_request.dart';
        final filePath = p.join(requestsPath, fileName);

        if (!updateOnly || !File(filePath).existsSync()) {
          final requestModel = ModelGenerator.generateRequestModel(
            function,
            strategy: modelStrategy,
          );
          if (requestModel.isNotEmpty) {
            await FileWriter.createDartFile(
              dirPath: requestsPath,
              fileName: fileName,
              content: requestModel,
            );
          }
        }
      }

      // Generate response model
      if (function.response != null) {
        final fileName = '${FileWriter.toSnakeCase(function.name)}_model.dart';
        final filePath = p.join(responsesPath, fileName);

        if (!updateOnly || !File(filePath).existsSync()) {
          final responseModel = ModelGenerator.generateResponseModel(
            function,
            strategy: modelStrategy,
          );
          if (responseModel.isNotEmpty) {
            await FileWriter.createDartFile(
              dirPath: responsesPath,
              fileName: fileName,
              content: responseModel,
            );
          }
        }
      }
    }
  }

  Future<void> _generateRepository(
    String dataPath,
    FeatureSchema schema,
    bool updateOnly,
  ) async {
    final snakeName = FileWriter.toSnakeCase(schema.name);
    final repoImplPath = p.join(dataPath, 'repositories');
    final fileName = '${snakeName}_repository_impl.dart';
    final filePath = p.join(repoImplPath, fileName);

    if (updateOnly && File(filePath).existsSync()) {
      final existingContent = await File(filePath).readAsString();
      for (final function in schema.functions) {
        if (!existingContent.contains('${function.name}(')) {
          final newMethod = RepositoryImplTemplate.generateMethod(function);
          await FileWriter.injectToClass(
            filePath: filePath,
            newContent: newMethod,
          );

          final imports = generateSingleFunctionModelImports(
            function,
            '../models',
          );
          for (final imp in imports) {
            await FileWriter.injectTopLevel(filePath: filePath, newContent: imp);
          }
        }
      }
    } else {
      // Repository implementation
      final implContent = RepositoryImplTemplate.generate(schema);
      await FileWriter.createDartFile(
        dirPath: repoImplPath,
        fileName: fileName,
        content: implContent,
      );
    }
  }
}
