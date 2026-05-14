import 'dart:io';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;
import 'package:clean_gen_cli/generator/models/feature_schema.dart';
import 'package:clean_gen_cli/generator/templates/repository_template.dart';
import 'package:clean_gen_cli/generator/utils/file_writer.dart';

import '../templates/usecase_template.dart';

class DomainLayerGenerator {
  final Logger logger;

  DomainLayerGenerator({required this.logger});

  Future<void> generate({
    required String basePath,
    required FeatureSchema schema,
    bool updateOnly = false,
  }) async {
    try {
      final domainPath = p.join(basePath, 'domain');

      // Generate/Update Repository interface
      await _generateRepositoryInterface(domainPath, schema, updateOnly);

      // Generate/Update UseCases
      await _generateUseCases(domainPath, schema, updateOnly);

      logger.info(
        '✓ Domain layer ${updateOnly ? 'updated' : 'generated'} for ${schema.name}',
      );
    } catch (e) {
      logger.err('Failed to generate domain layer: $e');
      rethrow;
    }
  }

  Future<void> _generateRepositoryInterface(
    String domainPath,
    FeatureSchema schema,
    bool updateOnly,
  ) async {
    final snakeName = FileWriter.toSnakeCase(schema.name);
    final repoPath = p.join(domainPath, 'repositories');
    final fileName = '${snakeName}_repository.dart';
    final filePath = p.join(repoPath, fileName);

    if (updateOnly && File(filePath).existsSync()) {
      final existingContent = await File(filePath).readAsString();
      for (final function in schema.functions) {
        if (!existingContent.contains('${function.name}(')) {
          final newMethod = RepositoryTemplate.generateMethod(function);
          await FileWriter.injectToClass(
            filePath: filePath,
            newContent: newMethod,
          );

          final imports = generateSingleFunctionModelImports(
            function,
            '../../data/models',
          );
          for (final imp in imports) {
            await FileWriter.injectTopLevel(filePath: filePath, newContent: imp);
          }
        }
      }
    } else {
      final content = RepositoryTemplate.generate(schema);
      await FileWriter.createDartFile(
        dirPath: repoPath,
        fileName: fileName,
        content: content,
      );
    }
  }

  Future<void> _generateUseCases(
    String domainPath,
    FeatureSchema schema,
    bool updateOnly,
  ) async {
    final useCasesPath = p.join(domainPath, 'use_cases');

    for (final function in schema.functions) {
      final snakeName = FileWriter.toSnakeCase(function.name);
      final fileName = '${snakeName}_use_case.dart';
      final filePath = p.join(useCasesPath, fileName);

      if (updateOnly && File(filePath).existsSync()) {
        continue; // Skip existing UseCases
      }

      final content = UseCaseTemplate.generate(function, schema);
      await FileWriter.createDartFile(
        dirPath: useCasesPath,
        fileName: fileName,
        content: content,
      );
    }
  }
}
