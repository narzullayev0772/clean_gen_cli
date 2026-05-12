import 'package:clean_gen_cli/generator/utils/file_writer.dart';

class RepositoryTemplate {
  static String generate(String featureName) {
    final camelName = FileWriter.toCamelCase(FileWriter.toSnakeCase(featureName));
    final className = '${camelName}Repository';

    return '''import 'package:core/resources/data_state.dart';

abstract class $className {
  /// Define your repository methods here
  /// Example:
  /// Future<DataState<List<SomeModel>?>> fetchSomeData(SomeQuery query);
  /// Future<DataState> createSomeData(SomeBody body);
}
''';
  }
}

class RepositoryImplTemplate {
  static String generate(String featureName) {
    final camelName = FileWriter.toCamelCase(FileWriter.toSnakeCase(featureName));
    final className = '${camelName}Repository';
    final implClassName = '${className}Impl';
    final apiServiceName = '${camelName}ApiService';
    final snakeName = FileWriter.toSnakeCase(featureName);

    return '''import 'package:core/resources/data_state.dart';
import '../data_sources/${snakeName}_api_service.dart';
import '../../domain/repositories/${snakeName}_repository.dart';

class $implClassName implements $className {
  final $apiServiceName _apiService;

  $implClassName(this._apiService);

  /// Implement your repository methods here
}
''';
  }
}

