import 'dart:convert';
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:clean_gen_cli/generator/models/feature_schema.dart';
import 'package:http/http.dart' as http;
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// A command that tests API endpoints defined in a configuration file.
///
/// It sends real HTTP requests to a live server and validates the response
/// against the examples provided in the config.
class TestCommand extends Command<void> {
  final Logger _logger;

  @override
  final String name = 'test';
  @override
  final String description =
      'Tests API endpoints defined in a config file against a live server.';

  /// Creates a new [TestCommand].
  TestCommand({Logger? logger}) : _logger = logger ?? Logger() {
    argParser.addOption(
      'base-url',
      abbr: 'b',
      help: 'Base URL for the API (e.g., https://api.example.com)',
      mandatory: true,
    );
    argParser.addOption(
      'token',
      abbr: 't',
      help: 'Bearer token for authentication.',
    );
    argParser.addMultiOption(
      'header',
      abbr: 'H',
      help: 'Additional headers in "key:value" format.',
    );
  }

  @override
  Future<void> run() async {
    final configPath = argResults?.rest.firstOrNull;

    if (configPath == null || configPath.isEmpty) {
      usageException('Please provide a config file path');
    }

    final baseUrl = argResults!['base-url'] as String;
    final token = argResults?['token'] as String?;
    final headerList = argResults?['header'] as List<String>? ?? [];

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    for (final h in headerList) {
      final parts = h.split(':');
      if (parts.length >= 2) {
        headers[parts[0].trim()] = parts.sublist(1).join(':').trim();
      }
    }

    await _testConfig(configPath, baseUrl, headers);
  }

  Future<void> _testConfig(
    String configPath,
    String baseUrl,
    Map<String, String> headers,
  ) async {
    final progress = _logger.progress('Loading config...');

    try {
      final configFile = File(p.absolute(configPath));
      if (!configFile.existsSync()) {
        progress.fail('Config file not found: $configPath');
        return;
      }

      final content = await configFile.readAsString();
      Map<String, dynamic> json;
      if (configPath.endsWith('.json')) {
        json = jsonDecode(content) as Map<String, dynamic>;
      } else {
        json = _yamlToMap(loadYaml(content)) as Map<String, dynamic>;
      }

      final schema = FeatureSchema.fromJson(json, GlobalConfig());
      progress.complete('Config loaded: ${schema.name}');

      _logger.info('\n🚀 Starting API Tests for feature: ${schema.name}');
      _logger.info('🌍 Base URL: $baseUrl\n');

      int successCount = 0;
      int failCount = 0;

      for (final func in schema.functions) {
        final result = await _testFunction(func, baseUrl, headers);
        if (result) {
          successCount++;
        } else {
          failCount++;
        }
      }

      _logger.info('\n--- Test Summary ---');
      if (failCount == 0) {
        _logger.success('✅ All $successCount functions passed!');
      } else {
        _logger.err('❌ $failCount functions failed.');
        _logger.info('✅ $successCount functions passed.');
      }
    } catch (e) {
      progress.fail('Test failed: $e');
    }
  }

  Future<bool> _testFunction(
    FunctionDef func,
    String baseUrl,
    Map<String, String> headers,
  ) async {
    final funcProgress = _logger.progress(
      'Testing ${func.name} [${func.method}]',
    );

    try {
      final url = Uri.parse('$baseUrl${func.api}');
      http.Response response;

      final body = func.request != null && !(func.query ?? false)
          ? jsonEncode(func.request)
          : null;

      final queryUrl = (func.query ?? false) && func.request is Map
          ? url.replace(
              queryParameters: (func.request as Map).map(
                (k, v) => MapEntry(k.toString(), v.toString()),
              ),
            )
          : url;

      switch (func.method) {
        case 'GET':
          response = await http.get(queryUrl, headers: headers);
          break;
        case 'POST':
          response = await http.post(url, headers: headers, body: body);
          break;
        case 'PUT':
          response = await http.put(url, headers: headers, body: body);
          break;
        case 'PATCH':
          response = await http.patch(url, headers: headers, body: body);
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers, body: body);
          break;
        default:
          funcProgress.fail('Unsupported method: ${func.method}');
          return false;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success status, now validate response body if expected response is defined
        if (func.response != null) {
          final actualBody = jsonDecode(response.body);
          final errors = _validateResponse(func.response, actualBody);

          if (errors.isEmpty) {
            funcProgress.complete(
              '${func.name} passed (HTTP ${response.statusCode})',
            );
            return true;
          } else {
            funcProgress.fail('${func.name} failed validation');
            for (final err in errors) {
              _logger.err('  - $err');
            }
            return false;
          }
        }

        funcProgress.complete(
          '${func.name} passed (HTTP ${response.statusCode})',
        );
        return true;
      } else {
        funcProgress.fail(
          '${func.name} failed with HTTP ${response.statusCode}',
        );
        _logger.err('  Response: ${response.body}');
        return false;
      }
    } catch (e) {
      funcProgress.fail('${func.name} encountered an error: $e');
      return false;
    }
  }

  List<String> _validateResponse(
    dynamic expected,
    dynamic actual, [
    String path = 'response',
  ]) {
    final errors = <String>[];

    if (expected is String && expected.startsWith('\$')) {
      // Magic model, check if actual exists. We can't strictly validate without the model def.
      if (actual == null) {
        errors.add('$path: Expected a model but got null');
      }
      return errors;
    }

    if (expected is Map) {
      if (actual is! Map) {
        errors.add('$path: Expected a Map but got ${actual.runtimeType}');
        return errors;
      }

      expected.forEach((key, expectedValue) {
        if (!actual.containsKey(key)) {
          errors.add('$path: Missing key "$key"');
        } else {
          errors.addAll(
            _validateResponse(expectedValue, actual[key], '$path.$key'),
          );
        }
      });
    } else if (expected is List) {
      if (actual is! List) {
        errors.add('$path: Expected a List but got ${actual.runtimeType}');
        return errors;
      }

      if (expected.isNotEmpty && actual.isNotEmpty) {
        // Usually, for lists in examples, we check if the elements match the first expected element
        errors.addAll(
          _validateResponse(expected.first, actual.first, '$path[0]'),
        );
      }
    } else {
      // Primitive types
      if (actual.runtimeType != expected.runtimeType && actual != null) {
        // Special case for int/double
        if (expected is num && actual is num) return errors;

        errors.add(
          '$path: Type mismatch. Expected ${expected.runtimeType} but got ${actual.runtimeType}',
        );
      }
    }

    return errors;
  }

  dynamic _yamlToMap(dynamic yaml) {
    if (yaml is YamlMap) {
      final map = <String, dynamic>{};
      yaml.forEach((key, value) {
        map[key.toString()] = _yamlToMap(value);
      });
      return map;
    } else if (yaml is YamlList) {
      return yaml.map((item) => _yamlToMap(item)).toList();
    } else {
      return yaml;
    }
  }
}
