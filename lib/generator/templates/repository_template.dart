import 'package:clean_gen_cli/generator/models/feature_schema.dart';
import 'package:clean_gen_cli/generator/utils/file_writer.dart';
import 'package:clean_gen_cli/generator/utils/model_generator.dart';

class RepositoryTemplate {
  static String generate(String featureName, List<FunctionDef> functions) {
    final camelName = FileWriter.toCamelCase(FileWriter.toSnakeCase(featureName));
    final className = '${camelName}Repository';

    final methods = functions.map((f) {
      final methodName = f.name;
      final requestType = ModelGenerator.getRequestModelType(f);
      final responseType = ModelGenerator.getResponseModelType(f);
      final returnType = responseType == 'dynamic' ? 'dynamic' : '$responseType?';
      return '  Future<DataState<$returnType>> $methodName($requestType params);';
    }).join('\n');

    return '''import 'package:core/resources/data_state.dart';

abstract class $className {
$methods
}
''';
  }
}

class RepositoryImplTemplate {
  static String generate(String featureName, List<FunctionDef> functions) {
    final camelName = FileWriter.toCamelCase(FileWriter.toSnakeCase(featureName));
    final className = '${camelName}Repository';
    final implClassName = '${className}Impl';
    final apiServiceName = '${camelName}ApiService';
    final snakeName = FileWriter.toSnakeCase(featureName);

    final methods = functions.map((f) {
      final methodName = f.name;
      final requestType = ModelGenerator.getRequestModelType(f);
      var responseType = ModelGenerator.getResponseModelType(f);
      final hasRequest = f.request != null;
      
      final returnType = responseType == 'dynamic' ? 'dynamic' : '$responseType?';

      return '''
  @override
  Future<DataState<$returnType>> $methodName($requestType params) async =>
      await handleResponse(response: _apiService.$methodName(${hasRequest ? 'params' : ''}));''';
    }).join('\n');

    return '''import 'package:core/core.dart';
import '../data_sources/${snakeName}_api_service.dart';
import '../../domain/repositories/${snakeName}_repository.dart';

class $implClassName with BaseRepository implements $className {
  final $apiServiceName _apiService;

  $implClassName(this._apiService);

$methods
}
''';
  }
}




