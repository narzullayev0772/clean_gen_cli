import 'package:clean_gen_cli/generator/models/feature_schema.dart';
import 'package:clean_gen_cli/generator/utils/file_writer.dart';

class UseCaseTemplate {
  static String generate(FunctionDef function, String featureName) {
    final camelName = FileWriter.toCamelCase(FileWriter.toSnakeCase(featureName));
    final className = '${FileWriter.toCamelCase(function.name)}UseCase';
    final repoName = '${camelName}Repository';

    return '''import 'package:core/core.dart';
import '../../repositories/${FileWriter.toSnakeCase(featureName)}_repository.dart';

class $className implements UseCase<DataState<dynamic>, dynamic> {
  final $repoName _repository;

  $className(this._repository);

  @override
  Future<DataState<dynamic>> call({required dynamic params}) async {
    // TODO: Implement use case logic
    throw UnimplementedError();
  }
}
''';
  }
}

