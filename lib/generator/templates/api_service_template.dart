import 'package:clean_gen_cli/generator/models/feature_schema.dart';
import 'package:clean_gen_cli/generator/utils/file_writer.dart';
import 'package:clean_gen_cli/generator/utils/model_generator.dart';

class ApiServiceTemplate {
  static String generate(String featureName, List<FunctionDef> functions) {
    final camelName = FileWriter.toCamelCase(FileWriter.toSnakeCase(featureName));
    final className = '${camelName}ApiService';

    final urlConstants = _generateUrlConstants(functions);
    final requestMethods = _generateRequestMethods(functions);

    return '''import 'package:core/resources/base_response.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

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
    final constants = functions.map((func) {
      final constName = FileWriter.toSnakeCase(func.name);
      return "  static const String _$constName = '${func.api}';";
    }).join('\n');

    return constants;
  }

  static String _generateRequestMethods(List<FunctionDef> functions) {
    final methods = functions.map((func) {
      final constName = FileWriter.toSnakeCase(func.name);
      final responseType = ModelGenerator.getResponseModelType(func);
      final requestType = ModelGenerator.getRequestModelType(func);
      final hasRequest = func.request != null;

      if (func.method == 'GET') {
        return '''  @GET(_$constName)
  Future<HttpResponse<BaseResponse<$responseType>>> ${func.name}();''';
      } else if (hasRequest) {
        return '''  @${func.method}(_$constName)
  Future<HttpResponse<BaseResponse<$responseType>>> ${func.name}(@Body() $requestType request);''';
      } else {
        return '''  @${func.method}(_$constName)
  Future<HttpResponse<BaseResponse<$responseType>>> ${func.name}();''';
      }
    }).join('\n\n  ');

    return methods;
  }
}



