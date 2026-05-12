import 'package:clean_gen_cli/generator/models/feature_schema.dart';
import 'package:clean_gen_cli/generator/utils/file_writer.dart';

class DITemplate {
  static String generate(String featureName, List<FunctionDef> functions) {
    final camelName = FileWriter.toCamelCase(FileWriter.toSnakeCase(featureName));
    final snakeName = FileWriter.toSnakeCase(featureName);
    final functionName = '${snakeName}DI';

    final apiServiceRegistration = _generateApiServiceRegistration(camelName);
    final repositoryRegistration = _generateRepositoryRegistration(camelName);
    final useCaseRegistrations = _generateUseCaseRegistrations(functions, camelName);
    final cubitsRegistration = _generateCubitsRegistration(functions, camelName);

    final useCaseImports = functions
        .map((f) => "import 'domain/use_cases/${FileWriter.toSnakeCase(f.name)}_use_case.dart';")
        .join('\n');

    return '''import 'data/data_sources/${snakeName}_api_service.dart';
import 'data/repositories/${snakeName}_repository_impl.dart';
import 'domain/repositories/${snakeName}_repository.dart';
$useCaseImports
import 'presentation/cubit/${snakeName}_cubit.dart';

Future<void> $functionName() async {
  // DataSources
$apiServiceRegistration

  // Repositories
$repositoryRegistration

  // UseCases
$useCaseRegistrations

  // Cubits
$cubitsRegistration
}
''';
  }

  static String _generateApiServiceRegistration(String camelName) {
    return '  locator.registerSingleton(${camelName}ApiService(locator()));';
  }

  static String _generateRepositoryRegistration(String camelName) {
    return '''  locator.registerSingleton<${camelName}Repository>(
    ${camelName}RepositoryImpl(locator()),
  );''';
  }

  static String _generateUseCaseRegistrations(List<FunctionDef> functions, String camelName) {
    if (functions.isEmpty) {
      return '  // Add your use case registrations here';
    }

    final registrations = functions
        .map((f) => "  locator.registerSingleton(${FileWriter.toCamelCase(f.name)}UseCase(locator()));")
        .join('\n');

    return registrations;
  }

  static String _generateCubitsRegistration(List<FunctionDef> functions, String camelName) {
    final useCases = functions
        .map((f) => "locator()")
        .join(',\n      ');

    return '''  locator.registerFactory<${camelName}Cubit>(
    () => ${camelName}Cubit(
      $useCases
    ),
  );''';
  }
}

