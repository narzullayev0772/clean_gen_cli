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
    final cubitsRegistration = _generateCubitsRegistration(camelName);

    return '''import 'package:get_it/get_it.dart';
import 'data/data_sources/${snakeName}_api_service.dart';
import 'data/repositories/${snakeName}_repository_impl.dart';
import 'domain/repositories/${snakeName}_repository.dart';
import 'domain/use_cases/index.dart';
import 'presentation/cubit/${snakeName}_cubit.dart';

final locator = GetIt.instance;

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

  static String _generateCubitsRegistration(String camelName) {
    return '''  locator.registerFactory<${camelName}Cubit>(
    () => ${camelName}Cubit(
      // Add use case dependencies here
    ),
  );''';
  }
}

