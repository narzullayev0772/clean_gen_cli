import 'package:clean_gen_cli/generator/models/feature_schema.dart';
import 'package:clean_gen_cli/generator/utils/file_writer.dart';

/// A template generator for the Dependency Injection (DI) layer.
///
/// It generates the registration logic for DataSources, Repositories, UseCases, and Cubits.
class DITemplate {
  /// Generates the complete source code for the feature's DI file.
  static String generate(FeatureSchema schema) {
    final camelName = FileWriter.toCamelCase(
      FileWriter.toSnakeCase(schema.name),
    );
    final snakeName = FileWriter.toSnakeCase(schema.name);
    final functionName = '${FileWriter.toLowerCamelCase(schema.name)}DI';

    final locatorName = schema.globalConfig.config['locator_name'] ?? 'locator';
    final locatorImport = schema.globalConfig.imports['locator'] ?? '';
    final locatorImportLine = locatorImport.isNotEmpty
        ? "import '$locatorImport';"
        : "";

    final apiServiceRegistration = _generateApiServiceRegistration(
      camelName,
      locatorName,
    );
    final repositoryRegistration = _generateRepositoryRegistration(
      camelName,
      locatorName,
    );
    final useCaseRegistrations = _generateUseCaseRegistrations(
      schema.functions,
      camelName,
      locatorName,
    );
    final cubitsRegistration = _generateCubitsRegistration(
      schema.functions,
      camelName,
      locatorName,
    );

    final useCaseImports = schema.functions
        .map(
          (f) =>
              "import 'domain/use_cases/${FileWriter.toSnakeCase(f.name)}_use_case.dart';",
        )
        .join('\n');

    return '''$locatorImportLine
import 'data/data_sources/${snakeName}_api_service.dart';
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

  static String _generateApiServiceRegistration(
    String camelName,
    String locatorName,
  ) {
    return '  $locatorName.registerSingleton(${camelName}ApiService($locatorName()));';
  }

  static String _generateRepositoryRegistration(
    String camelName,
    String locatorName,
  ) {
    return '''  $locatorName.registerSingleton<${camelName}Repository>(
    ${camelName}RepositoryImpl($locatorName()),
  );''';
  }

  static String _generateUseCaseRegistrations(
    List<FunctionDef> functions,
    String camelName,
    String locatorName,
  ) {
    if (functions.isEmpty) {
      return '  // Add your use case registrations here';
    }

    final registrations = functions
        .map(
          (f) =>
              "  $locatorName.registerSingleton(${FileWriter.toCamelCase(f.name)}UseCase($locatorName()));",
        )
        .join('\n');

    return registrations;
  }

  static String _generateCubitsRegistration(
    List<FunctionDef> functions,
    String camelName,
    String locatorName,
  ) {
    final useCases = functions.map((f) => "$locatorName()").join(',\n      ');

    return '''  $locatorName.registerFactory<${camelName}Cubit>(
    () => ${camelName}Cubit(
      $useCases
    ),
  );''';
  }
}
