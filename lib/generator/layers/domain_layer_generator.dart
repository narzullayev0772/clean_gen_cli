import 'package:path/path.dart' as p;
import 'package:clean_gen_cli/generator/models/feature_schema.dart';
import 'package:clean_gen_cli/generator/templates/usecase_template.dart';
import 'package:clean_gen_cli/generator/utils/file_writer.dart';
import 'package:mason/mason.dart';

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
      await _generateRepositoryInterface(domainPath, featureName);

      // Generate UseCases
      await _generateUseCases(domainPath, featureName, functions);

      // Generate Entities (placeholder)
      await _generateEntities(domainPath, featureName);

      logger.info('✓ Domain layer generated for $featureName');
    } catch (e) {
      logger.err('Failed to generate domain layer: $e');
      rethrow;
    }
  }

  Future<void> _generateRepositoryInterface(String domainPath, String featureName) async {
    final snakeName = FileWriter.toSnakeCase(featureName);
    final repoPath = p.join(domainPath, 'repositories');

    final content = '''import 'package:core/resources/data_state.dart';

abstract class ${FileWriter.toCamelCase(snakeName)}Repository {
  // TODO: Define repository abstract methods
}
''';

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

    // Generate index file for easier imports
    await _generateUseCaseIndex(useCasesPath, functions);
  }

  Future<void> _generateUseCaseIndex(String useCasesPath, List<FunctionDef> functions) async {
    final imports = functions
        .map((f) => "export '${FileWriter.toSnakeCase(f.name)}_use_case.dart';")
        .join('\n');

    final content = '''// Export all use cases
$imports
''';

    await FileWriter.createDartFile(
      dirPath: useCasesPath,
      fileName: 'index.dart',
      content: content,
    );
  }

  Future<void> _generateEntities(String domainPath, String featureName) async {
    final entitiesPath = p.join(domainPath, 'entities');

    final content = '''// Entities for $featureName feature
// TODO: Define your business entities here

// Example:
// class User {
//   final int id;
//   final String name;
//   final String email;
// 
//   const User({required this.id, required this.name, required this.email});
// }
''';

    await FileWriter.createDartFile(
      dirPath: entitiesPath,
      fileName: '._placeholder',
      content: content,
    );
  }
}

