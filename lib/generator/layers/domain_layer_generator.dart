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
  }) async {
    try {
      final domainPath = p.join(basePath, 'domain');

      // Generate Repository interface
      await _generateRepositoryInterface(domainPath, schema);

      // Generate UseCases
      await _generateUseCases(domainPath, schema);

      logger.info('✓ Domain layer generated for ${schema.name}');
    } catch (e) {
      logger.err('Failed to generate domain layer: $e');
      rethrow;
    }
  }

  Future<void> _generateRepositoryInterface(
    String domainPath,
    FeatureSchema schema,
  ) async {
    final snakeName = FileWriter.toSnakeCase(schema.name);
    final repoPath = p.join(domainPath, 'repositories');

    final content = RepositoryTemplate.generate(schema);

    await FileWriter.createDartFile(
      dirPath: repoPath,
      fileName: '${snakeName}_repository.dart',
      content: content,
    );
  }

  Future<void> _generateUseCases(
    String domainPath,
    FeatureSchema schema,
  ) async {
    final useCasesPath = p.join(domainPath, 'use_cases');

    for (final function in schema.functions) {
      final snakeName = FileWriter.toSnakeCase(function.name);

      final content = UseCaseTemplate.generate(function, schema);

      await FileWriter.createDartFile(
        dirPath: useCasesPath,
        fileName: '${snakeName}_use_case.dart',
        content: content,
      );
    }
  }
}

