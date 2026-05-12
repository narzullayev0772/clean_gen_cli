import 'package:clean_gen_cli/generator/models/feature_schema.dart';
import 'package:clean_gen_cli/generator/utils/file_writer.dart';

import '../utils/model_generator.dart';

class CubitTemplate {
  static String generate(String featureName, List<FunctionDef> functions) {
    final camelName = FileWriter.toCamelCase(FileWriter.toSnakeCase(featureName));
    final className = '${camelName}Cubit';
    final stateName = '${camelName}State';
    final snakeName = FileWriter.toSnakeCase(featureName);

    final dependencies = _generateDependencies(functions);
    final constructor = _generateConstructor(className, functions);
    final methods = _generateMethods(functions, camelName);
    final modelImports = _generateModelImports(functions, '../../data/models');

    final useCaseImportsList = functions
        .map((f) => "import '../../../domain/use_cases/${FileWriter.toSnakeCase(f.name)}_use_case.dart';")
        .toList()..sort();
    final useCaseImports = useCaseImportsList.join('\n');

    return '''import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:core/resources/base_state.dart';
import 'package:core/resources/base_query.dart';
import 'package:core/resources/base_pagination_state.dart';
import '../../../../core/utils/fetcher.dart';
$useCaseImports
$modelImports

part '${snakeName}_state.dart';

class $className extends Cubit<$stateName> {
$dependencies

  $constructor

$methods
}
''';
  }

  static String _generateDependencies(List<FunctionDef> functions) {
    return functions
        .map((f) => "  final ${FileWriter.toCamelCase(f.name)}UseCase _${f.name[0].toLowerCase()}${f.name.substring(1)}UseCase;")
        .join('\n');
  }

  static String _generateConstructor(String className, List<FunctionDef> functions) {
    final params = functions
        .map((f) => "this._${f.name[0].toLowerCase()}${f.name.substring(1)}UseCase,")
        .join('\n    ');

    return '''  $className(
    $params
  ) : super(AuthState.initial());''';
  }

  static String _generateMethods(List<FunctionDef> functions, String camelName) {
    return functions.map((f) {
      final useCaseVar = '_${f.name[0].toLowerCase()}${f.name.substring(1)}UseCase';
      final methodName = f.name;
      final stateField = '${f.name}State';
      final requestType = ModelGenerator.getRequestModelType(f);

      if (f.pagination) {
        return '''
  Future<void> $methodName($requestType query) => Fetcher.fetchWithPaginate(
    isRefresh: query.page == 1,
    fetcher: () => $useCaseVar.call(
      params: query.copyWith(
        page: query.page ?? state.$stateField.query.page,
        size: query.size ?? state.$stateField.query.size,
      ),
    ),
    state: state.$stateField,
    emitter: (newState) => emit(state.copyWith($stateField: newState)),
  );''';
      } else {
        return '''
  Future<void> $methodName($requestType params) => Fetcher.fetchWithBase(
    fetcher: () => $useCaseVar.call(params: params),
    state: state.$stateField,
    emitter: (newState) => emit(state.copyWith($stateField: newState)),
  );''';
      }
    }).join('\n');
  }

  static String _generateModelImports(List<FunctionDef> functions, String relativePath) {
    final imports = <String>{};
    for (final f in functions) {
      if (f.request != null) {
        imports.add("import '$relativePath/requests/${FileWriter.toSnakeCase(f.name)}_request.dart';");
      }
      if (f.response != null) {
        imports.add("import '$relativePath/responses/${FileWriter.toSnakeCase(f.name)}_model.dart';");
      }
    }
    final sortedImports = imports.toList()..sort();
    return sortedImports.join('\n');
  }
}

class CubitStateTemplate {
  static String generate(String featureName, List<FunctionDef> functions) {
    final camelName = FileWriter.toCamelCase(FileWriter.toSnakeCase(featureName));
    final stateName = '${camelName}State';

    final modelImports = CubitTemplate._generateModelImports(functions, '../../data/models');

    final fields = functions.map((f) {
      final responseType = ModelGenerator.getResponseModelType(f);
      final type = f.pagination ? 'BasePaginationState<$responseType>' : 'BaseState<$responseType>';
      return '  final $type ${f.name}State;';
    }).join('\n');

    final constructorParams = functions.map((f) => '    required this.${f.name}State,').join('\n');

    final copyWithParams = functions.map((f) {
      final responseType = ModelGenerator.getResponseModelType(f);
      final type = f.pagination ? 'BasePaginationState<$responseType>' : 'BaseState<$responseType>';
      return '    $type? ${f.name}State,';
    }).join('\n');

    final copyWithAssignments = functions.map((f) => '      ${f.name}State: ${f.name}State ?? this.${f.name}State,').join('\n');

    final initialFields = functions.map((f) {
      final responseType = ModelGenerator.getResponseModelType(f);
      if (f.pagination) {
        return '      ${f.name}State: BasePaginationState<$responseType>(query: BasePagingQuery()),';
      } else {
        return '      ${f.name}State: BaseState<$responseType>.initial(),';
      }
    }).join('\n');

    return '''part of '${FileWriter.toSnakeCase(featureName)}_cubit.dart';

$modelImports

class $stateName {
$fields

  $stateName({
$constructorParams
  });

  $stateName copyWith({
$copyWithParams
  }) {
    return $stateName(
$copyWithAssignments
    );
  }

  factory $stateName.initial() {
    return $stateName(
$initialFields
    );
  }
}
''';
  }
}


