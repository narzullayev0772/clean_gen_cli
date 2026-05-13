import 'package:clean_gen_cli/generator/models/feature_schema.dart';
import 'package:clean_gen_cli/generator/utils/file_writer.dart';

class DITemplate {
  static String generate(FeatureSchema schema) {
    final camelName = FileWriter.toCamelCase(FileWriter.toSnakeCase(schema.name));
    final snakeName = FileWriter.toSnakeCase(schema.name);
    final functionName = '${FileWriter.toLowerCamelCase(schema.name)}DI';

    final apiServiceRegistration = _generateApiServiceRegistration(camelName);
    final repositoryRegistration = _generateRepositoryRegistration(camelName);
    final useCaseRegistrations = _generateUseCaseRegistrations(schema.functions, camelName);
    final cubitsRegistration = _generateCubitsRegistration(schema.functions, camelName);

    final useCaseImports = schema.functions
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
