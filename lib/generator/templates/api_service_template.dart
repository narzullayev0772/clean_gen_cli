import 'package:clean_gen_cli/generator/models/feature_schema.dart';
import 'package:clean_gen_cli/generator/utils/file_writer.dart';
import 'package:clean_gen_cli/generator/utils/model_generator.dart';

class ApiServiceTemplate {
  static String generate(FeatureSchema schema) {
    final featureName = schema.name;
    final functions = schema.functions;
    final camelName = FileWriter.toCamelCase(
      FileWriter.toSnakeCase(featureName),
    );
    final className = '${camelName}ApiService';

    final urlConstants = _generateUrlConstants(functions);
    final requestMethods = _generateRequestMethods(functions);
    final modelImports = _generateModelImports(functions);

    final baseResponseImport =
        schema.globalConfig.imports['base_response'] ?? '';
    final baseResponseImportLine = baseResponseImport.isNotEmpty
        ? "import '$baseResponseImport';"
        : "";

    return '''import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
$baseResponseImportLine
$modelImports

part '${FileWriter.toSnakeCase(featureName)}_api_service.g.dart';

@RestApi()
abstract class $className {
  factory $className(Dio dio, {String baseUrl, ParseErrorLogger? errorLogger}) = _$className;

  /// URL Endpoints
$urlConstants

  /// Request Methods
$requestMethods
}
''';
  }

  static String _generateUrlConstants(List<FunctionDef> functions) {
    final constants = functions.map(generateUrlConstant).join('\n');

    return constants;
  }

  static String generateUrlConstant(FunctionDef func) {
    final constName = FileWriter.toLowerCamelCase(func.name);
    return "  static const String _$constName = '${func.api}';";
  }

  static String _generateRequestMethods(List<FunctionDef> functions) {
    final methods = functions.map(generateRequestMethod).join('\n\n  ');

    return methods;
  }

  static String generateRequestMethod(FunctionDef func) {
    final constName = FileWriter.toLowerCamelCase(func.name);
    final responseType = ModelGenerator.getResponseModelType(func);
    final requestType = ModelGenerator.getRequestModelType(func);
    final hasRequest = func.request != null;

    String params = '';
    if (hasRequest) {
      // Default value is false (Body)
      final useQuery = func.query ?? false;
      final annotation = useQuery ? '@Queries()' : '@Body()';
      params = '$annotation $requestType request';
    }

    return '''  @${func.method}(_$constName)
  Future<HttpResponse<BaseResponse<$responseType>>> ${func.name}($params);''';
  }

  static String _generateModelImports(List<FunctionDef> functions) {
    final imports = <String>{};
    for (final f in functions) {
      imports.addAll(generateSingleFunctionModelImports(f));
    }
    final sortedImports = imports.toList()..sort();
    return sortedImports.join('\n');
  }

  static Set<String> generateSingleFunctionModelImports(FunctionDef f) {
    final imports = <String>{};
    if (f.request != null && !ModelGenerator.isMagic(f.request)) {
      imports.add(
        "import '../models/requests/${FileWriter.toSnakeCase(f.name)}_request.dart';",
      );
    }
    if (f.response != null && !ModelGenerator.isMagic(f.response)) {
      imports.add(
        "import '../models/responses/${FileWriter.toSnakeCase(f.name)}_model.dart';",
      );
    }
    return imports;
  }
}
