import 'package:clean_gen_cli/generator/models/feature_schema.dart';
import 'package:clean_gen_cli/generator/utils/file_writer.dart';
import 'package:clean_gen_cli/generator/utils/model_generator.dart';

class UseCaseTemplate {
  static String generate(FunctionDef function, String featureName) {
    final camelFeatureName = FileWriter.toCamelCase(FileWriter.toSnakeCase(featureName));
    final className = '${FileWriter.toCamelCase(function.name)}UseCase';
    final repoName = '${camelFeatureName}Repository';
    final requestType = ModelGenerator.getRequestModelType(function);
    final responseType = ModelGenerator.getResponseModelType(function);
    final returnType = responseType == 'dynamic' ? 'dynamic' : '$responseType?';

    return '''import 'package:core/core.dart';
import '../../repositories/${FileWriter.toSnakeCase(featureName)}_repository.dart';

class $className implements UseCase<DataState<$returnType>, $requestType> {
  final $repoName _repository;

  $className(this._repository);

  @override
  Future<DataState<$returnType>> call({required $requestType params}) async =>
      await _repository.${function.name}(params);
}
''';
  }
}

