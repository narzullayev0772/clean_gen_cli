import 'package:clean_gen_cli/generator/models/feature_schema.dart';
import 'package:clean_gen_cli/generator/utils/file_writer.dart';

class ModelGenerator {
  static bool isMagic(dynamic value) {
    if (value is String && value.startsWith('\$')) return true;
    if (value is List && value.isNotEmpty && isMagic(value.first)) return true;
    return false;
  }

  static String _getMagicName(dynamic value) {
    if (value is String && value.startsWith('\$')) return value.substring(1);
    if (value is List && value.isNotEmpty) return _getMagicName(value.first);
    return '';
  }

  /// Generate request model class from schema
  static String generateRequestModel(FunctionDef function, {String strategy = 'empty'}) {
    if (function.request == null || isMagic(function.request)) {
      return '';
    }

    final modelName = '${FileWriter.toCamelCase(function.name)}RequestBody';
    final fileName = '${FileWriter.toSnakeCase(function.name)}_request';

    return _generateModel(modelName, fileName, function.request, strategy);
  }

  /// Generate response model class from schema
  static String generateResponseModel(FunctionDef function, {String strategy = 'empty'}) {
    if (function.response == null || isMagic(function.response)) {
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

    final fields = <String>[]; // declarations
    final constructorParams = <String>[]; // named params
    final fromJsonAssignments = <String>[]; // inside fromJson constructor body
    final toJsonLines = <String>[]; // inside toJson

    bool needsCoreModelsImport = false;

    data.forEach((key, value) {
      final dartKey = FileWriter.toLowerCamelCase(key.toString());
      final type = _getDartType(value);

      // mutable nullable field
      fields.add('  $type? $dartKey;');
      constructorParams.add('this.$dartKey,');

      // fromJson assignment
      if (type.startsWith('List<')) {
        final inner = type.substring(5, type.length - 1);
        if (_isPrimitive(inner) || inner == 'dynamic' || inner.startsWith('Map<')) {
          // primitive list: assign directly
          fromJsonAssignments.add("    $dartKey = json['$key'];");
        } else {
          // list of models: use foreach pattern for safety and readability
          needsCoreModelsImport = true;
          fromJsonAssignments.add("    if (json['$key'] != null) {\n      $dartKey = [];\n      json['$key'].forEach((v) {\n        $dartKey?.add($inner.fromJson(v));\n      });\n    }");
        }

        // toJson for list
        if (_isPrimitive(inner) || inner == 'dynamic' || inner.startsWith('Map<')) {
          toJsonLines.add("    map['$key'] = $dartKey;");
        } else {
          toJsonLines.add("    if ($dartKey != null) {\n      map['$key'] = $dartKey?.map((e) => e.toJson()).toList();\n    }");
        }
      } else if (type == 'Map<String, dynamic>') {
        // assign map directly
        fromJsonAssignments.add("    $dartKey = json['$key'];");
        toJsonLines.add("    map['$key'] = $dartKey;");
      } else if (_isPrimitive(type) || type == 'dynamic') {
        // assign primitive directly from json (avoid runtime cast in generated code)
        fromJsonAssignments.add("    $dartKey = json['$key'];");
        toJsonLines.add("    map['$key'] = $dartKey;");
      } else {
        // custom model
        needsCoreModelsImport = true;
        fromJsonAssignments.add("    $dartKey = json['$key'] != null ? $type.fromJson(json['$key']) : null;");
        toJsonLines.add("    if ($dartKey != null) {\n      map['$key'] = $dartKey?.toJson();\n    }");
      }
    });

    // copyWith params and assignments
    final copyWithParams = data.entries.map((e) {
      final dartKey = FileWriter.toLowerCamelCase(e.key.toString());
      final type = _getDartType(e.value);
      return '    $type? $dartKey,';
    }).join('\n');

    final copyWithAssignments = data.keys.map((key) {
      final dartKey = FileWriter.toLowerCamelCase(key.toString());
      return '      $dartKey: $dartKey ?? this.$dartKey,';
    }).join('\n');

    final importLine = needsCoreModelsImport ? "import 'package:uyqur_core/core/models/models.dart';\n\n" : '';

    return '''${importLine}class $className {
${fields.join('\n')}

  $className({
    ${constructorParams.join('\n    ')}
  });

  $className.fromJson(dynamic json) {
${fromJsonAssignments.join('\n')}
  }

  ${copyWithParams.isEmpty ? '' : ''}
  $className copyWith({
$copyWithParams
  }) => $className(
$copyWithAssignments
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
${toJsonLines.join('\n')}
    return map;
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
    if (value is String) {
      if (value.startsWith('\$')) return value.substring(1);
      return 'String';
    }
    if (value is int) return 'int';
    if (value is double) return 'double';
    if (value is bool) return 'bool';
    if (value is List) {
      if (value.isEmpty) return 'List<dynamic>';
      return 'List<${_getDartType(value.first)}>';
    }
    if (value is Map) return 'Map<String, dynamic>';
    return 'dynamic';
  }

  static bool _isPrimitive(String type) {
    return ['String', 'int', 'double', 'bool', 'num', 'dynamic'].contains(type);
  }

  /// Get request model type name
  static String getRequestModelType(FunctionDef function) {
    if (function.request == null) {
      return 'dynamic';
    }
    if (isMagic(function.request)) {
      return _getMagicName(function.request);
    }
    return '${FileWriter.toCamelCase(function.name)}RequestBody';
  }

  /// Get response model type name with List handling
  static String getResponseModelType(FunctionDef function) {
    if (function.response == null) {
      return 'dynamic';
    }

    if (isMagic(function.response)) {
      final name = _getMagicName(function.response);
      if (function.response is List || function.pagination) {
        return 'List<$name>';
      }
      return name;
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
    if (isMagic(function.response)) {
      return _getMagicName(function.response);
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
