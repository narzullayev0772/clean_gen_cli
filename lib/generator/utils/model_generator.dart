import 'package:clean_gen_cli/generator/models/feature_schema.dart';
import 'package:clean_gen_cli/generator/utils/file_writer.dart';

class ModelGenerator {
  /// Generate request model class from schema
  static String generateRequestModel(FunctionDef function, {String strategy = 'empty'}) {
    if (function.request == null) {
      return '';
    }

    final modelName = '${FileWriter.toCamelCase(function.name)}RequestBody';
    final fileName = '${FileWriter.toSnakeCase(function.name)}_request';

    return _generateModel(modelName, fileName, function.request, strategy);
  }

  /// Generate response model class from schema
  static String generateResponseModel(FunctionDef function, {String strategy = 'empty'}) {
    if (function.response == null) {
      return '';
    }

    dynamic responseData = function.response;
    if (responseData is List && responseData.isNotEmpty) {
      responseData = responseData.first;
    }

    final modelName = '${FileWriter.toCamelCase(function.name)}Model';
    final fileName = '${FileWriter.toSnakeCase(function.name)}_model';

    return _generateModel(modelName, fileName, responseData, strategy);
  }

  static String _generateModel(String className, String fileName, dynamic data, String strategy) {
    if (strategy == 'serialize') {
      return _generateSerializableModel(className, fileName, data);
    } else if (strategy == 'generate') {
      return _generatePlainModel(className, data);
    } else {
      return _generateEmptyModel(className, data);
    }
  }

  static String _generateEmptyModel(String className, dynamic data) {
    final jsonSchema = _formatJsonComment(data);
    return '''// Generated from config
$jsonSchema
class $className {
  // TODO: Define fields
  //
  // const $className();
}
''';
  }

  static String _generatePlainModel(String className, dynamic data) {
    if (data is! Map) return _generateEmptyModel(className, data);

    final fields = <String>[];
    final constructorParams = <String>[];
    final fromJsonLines = <String>[];
    final toJsonLines = <String>[];

    data.forEach((key, value) {
      final dartKey = FileWriter.toLowerCamelCase(key.toString());
      final type = _getDartType(value);

      fields.add('  final $type? $dartKey;');
      constructorParams.add('this.$dartKey');
      fromJsonLines.add("      $dartKey: json['$key'] as $type?,");
      toJsonLines.add("      '$key': $dartKey,");
    });

    return '''class $className {
${fields.join('\n')}

  const $className({
    ${constructorParams.join(',\n    ')},
  });

  factory $className.fromJson(Map<String, dynamic> json) {
    return $className(
${fromJsonLines.join('\n')}
    );
  }

  Map<String, dynamic> toJson() {
    return {
${toJsonLines.join('\n')}
    };
  }
}
''';
  }

  static String _generateSerializableModel(String className, String fileName, dynamic data) {
    if (data is! Map) return _generateEmptyModel(className, data);

    final fields = <String>[];
    final constructorParams = <String>[];

    data.forEach((key, value) {
      final dartKey = FileWriter.toLowerCamelCase(key.toString());
      final type = _getDartType(value);

      fields.add('  final $type? $dartKey;');
      constructorParams.add('this.$dartKey');
    });

    return '''import 'package:json_annotation/json_annotation.dart';

part '$fileName.g.dart';

@JsonSerializable()
class $className {
${fields.join('\n')}

  const $className({
    ${constructorParams.join(',\n    ')},
  });

  factory $className.fromJson(Map<String, dynamic> json) => _\$${className}FromJson(json);

  Map<String, dynamic> toJson() => _\$${className}ToJson(this);
}
''';
  }

  static String _getDartType(dynamic value) {
    if (value is int) return 'int';
    if (value is double) return 'double';
    if (value is bool) return 'bool';
    if (value is String) return 'String';
    if (value is List) {
      if (value.isEmpty) return 'List<dynamic>';
      return 'List<${_getDartType(value.first)}>';
    }
    if (value is Map) return 'Map<String, dynamic>';
    return 'dynamic';
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

    if (function.response is List || function.pagination) {
      return 'List<$modelName>';
    }

    return modelName;
  }

  /// Get base response model type name (without List)
  static String getBaseResponseModelType(FunctionDef function) {
    if (function.response == null) {
      return 'dynamic';
    }
    return '${FileWriter.toCamelCase(function.name)}Model';
  }

  /// Format JSON schema as comment block
  static String _formatJsonComment(dynamic schema) {
    if (schema == null) return '';

    try {
      final jsonStr = _prettyJson(schema);
      final lines = jsonStr.split('\n').map((line) => '// $line').join('\n');
      return '/*\n$lines\n*/\n';
    } catch (e) {
      return '// Schema available in config\n';
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
