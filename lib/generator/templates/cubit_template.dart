import 'package:clean_gen_cli/generator/models/feature_schema.dart';
import 'package:clean_gen_cli/generator/utils/file_writer.dart';

class CubitTemplate {
  static String generate(String featureName, List<FunctionDef> functions) {
    final camelName = FileWriter.toCamelCase(FileWriter.toSnakeCase(featureName));
    final className = '${camelName}Cubit';
    final stateName = '${camelName}State';

    final dependencies = _generateDependencies(functions, featureName);
    final constructor = _generateConstructor(className, functions, featureName);
    final methods = _generateMethods(functions);

    return '''import 'package:bloc/bloc.dart';
import 'package:core/core.dart';

part '${FileWriter.toSnakeCase(featureName)}_state.dart';

class $className extends Cubit<$stateName> {
$dependencies

  $constructor

  // TODO: Add cubit methods
$methods
}
''';
  }

  static String _generateDependencies(List<FunctionDef> functions, String featureName) {
    final useCases = functions
        .map((f) => "  final ${FileWriter.toCamelCase(f.name)}UseCase _${f.name[0].toLowerCase()}${f.name.substring(1)}UseCase;")
        .join('\n');

    return useCases;
  }

  static String _generateConstructor(String className, List<FunctionDef> functions, String featureName) {
    final params = functions
        .map((f) => "this._${f.name[0].toLowerCase()}${f.name.substring(1)}UseCase,")
        .join('\n    ');

    final camelName = FileWriter.toCamelCase(FileWriter.toSnakeCase(featureName));
    final stateName = '${camelName}State';

    return '''$className(
    $params
  ) : super($stateName.initial());''';
  }

  static String _generateMethods(List<FunctionDef> functions) {
    final methods = functions
        .map((f) => '''
  Future<void> ${f.name}() async {
    // TODO: Implement ${f.name}
  }''')
        .join('\n');

    return methods;
  }
}

class CubitStateTemplate {
  static String generate(String featureName) {
    final camelName = FileWriter.toCamelCase(FileWriter.toSnakeCase(featureName));
    final stateName = '${camelName}State';

    return '''part of '${FileWriter.toSnakeCase(featureName)}_cubit.dart';

class $stateName {
  const $stateName();

  factory $stateName.initial() => const $stateName();
}
''';
  }
}

