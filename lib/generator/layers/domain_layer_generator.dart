import 'package:path/path.dart' as p;
import 'package:clean_gen_cli/generator/models/feature_schema.dart';
import 'package:clean_gen_cli/generator/templates/repository_template.dart';
import 'package:clean_gen_cli/generator/utils/file_writer.dart';
import 'package:mason/mason.dart';

import '../templates/usecase_template.dart';

class DomainLayerGenerator {
  final Logger logger;

  DomainLayerGenerator({required this.logger});

  Future<void> generate({
    required String basePath,
    required String featureName,
    required List<FunctionDef> functions,
  }) async {
    try {
      final domainPath = p.join(basePath, 'domain');

      // Generate Repository interface
      await _generateRepositoryInterface(domainPath, featureName, functions);

      // Generate UseCases
      await _generateUseCases(domainPath, featureName, functions);

      logger.info('✓ Domain layer generated for $featureName');
    } catch (e) {
      logger.err('Failed to generate domain layer: $e');
      rethrow;
    }
  }

  Future<void> _generateRepositoryInterface(
    String domainPath,
    String featureName,
    List<FunctionDef> functions,
  ) async {
    final snakeName = FileWriter.toSnakeCase(featureName);
    final repoPath = p.join(domainPath, 'repositories');

    final content = RepositoryTemplate.generate(featureName, functions);

    await FileWriter.createDartFile(
      dirPath: repoPath,
      fileName: '${snakeName}_repository.dart',
      content: content,
    );
  }

  Future<void> _generateUseCases(
    String domainPath,
    String featureName,
    List<FunctionDef> functions,
  ) async {
    final useCasesPath = p.join(domainPath, 'use_cases');

    for (final function in functions) {
      final snakeName = FileWriter.toSnakeCase(function.name);

      final content = UseCaseTemplate.generate(function, featureName);

      await FileWriter.createDartFile(
        dirPath: useCasesPath,
        fileName: '${snakeName}_use_case.dart',
        content: content,
      );
    }
  }
}

