import 'package:clean_gen_cli/generator/models/feature_schema.dart';
import 'package:clean_gen_cli/generator/utils/file_writer.dart';

class ModelGenerator {
  /// Generate request model class from schema
  static String generateRequestModel(FunctionDef function) {
    if (function.request == null) {
      return ''; // No request model needed
    }

    final modelName = '${FileWriter.toCamelCase(function.name)}RequestBody';
    final jsonSchema = _formatJsonComment(function.request);

    return '''// Generated from .arch.json
$jsonSchema
class $modelName {
  // TODO: Define request fields
  // Example:
  // final String email;
  // final String password;
  //
  // const $modelName({
  //   required this.email,
  //   required this.password,
  // });
}
''';
  }

  /// Generate response model class from schema
  static String generateResponseModel(FunctionDef function) {
    if (function.response == null) {
      return ''; // No response model needed
    }

    final isListResponse = function.response is List;
    final modelName = isListResponse
        ? '${FileWriter.toCamelCase(function.name)}Model'
        : '${FileWriter.toCamelCase(function.name)}Model';

    final jsonSchema = _formatJsonComment(function.response);

    return '''// Generated from .arch.json
$jsonSchema
class $modelName {
  // TODO: Define response fields
  // Example:
  // final int id;
  // final String name;
  // final String email;
  //
  // const $modelName({
  //   required this.id,
  //   required this.name,
  //   required this.email,
  // });
}
''';
  }

  /// Get request model type name
  static String getRequestModelType(FunctionDef function) {
    if (function.request == null) {
      return 'dynamic';
    }
    return '${FileWriter.toCamelCase(function.name)}RequestBody';
  }

  /// Get response model type name with List handling
  static String getResponseModelType(FunctionDef function) {
    if (function.response == null) {
      return 'dynamic';
    }

    final modelName = '${FileWriter.toCamelCase(function.name)}Model';

    if (function.response is List) {
      return 'List<$modelName>';
    }

    return modelName;
  }

  /// Format JSON schema as comment block
  static String _formatJsonComment(dynamic schema) {
    if (schema == null) return '';

    try {
      final jsonStr = _prettyJson(schema);
      final lines = jsonStr.split('\n').map((line) => '// $line').join('\n');
      return '/*\n$lines\n*/\n';
    } catch (e) {
      return '// Schema available in .arch.json\n';
    }
  }

  /// Pretty print JSON
  static String _prettyJson(dynamic obj, {int indent = 0}) {
    final spaces = ' ' * indent;

    if (obj is List) {
      if (obj.isEmpty) return '[]';
      final items = obj.map((e) => _prettyJson(e, indent: indent + 2)).join(',\n$spaces');
      return '[\n$spaces$items\n$spaces]';
    } else if (obj is Map) {
      if (obj.isEmpty) return '{}';
      final entries = obj.entries.map((e) {
        final value = _prettyJson(e.value, indent: indent + 2);
        return '"${e.key}": $value';
      }).join(',\n$spaces');
      return '{\n$spaces$entries\n$spaces}';
    } else if (obj is String) {
      return '"$obj"';
    } else if (obj is num) {
      return obj.toString();
    } else if (obj is bool) {
      return obj.toString();
    } else {
      return 'null';
    }
  }
}

