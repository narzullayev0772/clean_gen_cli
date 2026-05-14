import 'dart:convert';
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:clean_gen_cli/generator/feature_generator.dart';
import 'package:clean_gen_cli/generator/models/feature_schema.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class UpdateCommand extends Command<void> {
  final Logger _logger;

  @override
  final String name = 'update';
  @override
  final String description =
      'Updates an existing feature with new functions from a config file.';

  UpdateCommand({Logger? logger}) : _logger = logger ?? Logger() {
    argParser.addOption(
      'output',
      abbr: 'o',
      defaultsTo: 'lib/src/features',
      help: 'Output path where the feature exists.',
    );
    argParser.addOption(
      'model',
      abbr: 'm',
      defaultsTo: 'generate',
      allowed: ['empty', 'serialize', 'generate'],
      help: 'Model generation strategy.',
    );
  }

  @override
  Future<void> run() async {
    final configPath = argResults?.rest.firstOrNull;

    if (configPath == null || configPath.isEmpty) {
      usageException(
        'Please provide a config file path\n'
        'Example: clean_gen update config/auth.config.json',
      );
    }

    await _updateFromConfig(configPath);
  }

  Future<void> _updateFromConfig(String configPath) async {
    final progress = _logger.progress('Loading config for update...');

    try {
      final resolvedPath = p.absolute(configPath);
      final configFile = File(resolvedPath);

      if (!configFile.existsSync()) {
        progress.fail('Config file not found: $resolvedPath');
        return;
      }

      final fileName = p.basename(resolvedPath);
      final featureName = _extractFeatureName(fileName);

      if (featureName.isEmpty) {
        progress.fail('Invalid config filename. Expected <feature-name>.config.json');
        return;
      }

      final configContent = await configFile.readAsString();
      Map<String, dynamic> configJson;

      if (resolvedPath.endsWith('.json')) {
        configJson = jsonDecode(configContent) as Map<String, dynamic>;
      } else {
        final yaml = loadYaml(configContent);
        configJson = _yamlToMap(yaml) as Map<String, dynamic>;
      }

      final globalConfig = await _loadGlobalConfig();
      final schema = FeatureSchema.fromJson(configJson, globalConfig);

      if (!schema.isValid()) {
        progress.fail('Invalid schema in $configPath');
        return;
      }

      progress.complete('Config loaded: $featureName');

      final outputPath = argResults!['output'] as String;
      final featureOutputPath = p.join(outputPath, featureName);

      if (!Directory(featureOutputPath).existsSync()) {
        progress.fail('Feature directory not found at $featureOutputPath. Use "create" first.');
        return;
      }

      final modelStrategy = argResults!['model'] as String;
      final generator = FeatureGenerator(logger: _logger);
      
      await generator.generate(
        basePath: featureOutputPath,
        schema: schema,
        modelStrategy: modelStrategy,
        updateOnly: true,
      );

    } catch (e) {
      progress.fail('Failed to update feature: $e');
      _logger.err(e.toString());
      rethrow;
    }
  }

  String _extractFeatureName(String fileName) {
    if (fileName.endsWith('.config.json')) {
      return fileName.substring(0, fileName.length - '.config.json'.length);
    }
    if (fileName.endsWith('.config.yaml')) {
      return fileName.substring(0, fileName.length - '.config.yaml'.length);
    }
    if (fileName.endsWith('.config.yml')) {
      return fileName.substring(0, fileName.length - '.config.yml'.length);
    }
    return '';
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

  Future<GlobalConfig> _loadGlobalConfig() async {
    final configFile = File(p.join('config', 'config.json'));
    if (!configFile.existsSync()) {
      return GlobalConfig();
    }

    try {
      final content = await configFile.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      return GlobalConfig.fromJson(json);
    } catch (e) {
      _logger.warn('Failed to load global config: $e. Using defaults.');
      return GlobalConfig();
    }
  }
}
