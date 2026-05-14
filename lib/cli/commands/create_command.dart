import 'dart:convert';
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:clean_gen_cli/generator/feature_generator.dart';
import 'package:clean_gen_cli/generator/models/feature_schema.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class CreateCommand extends Command<void> {
  final Logger _logger;

  @override
  final String name = 'create';
  @override
  final String description =
      'Creates feature from config file. Generates folders only if no functions, '
      'or complete feature with all files if functions are defined.';

  CreateCommand({Logger? logger}) : _logger = logger ?? Logger() {
    argParser.addOption(
      'output',
      abbr: 'o',
      defaultsTo: 'lib/src/features',
      help: 'Output path for the generated feature.',
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
        'Example: clean_gen create config/auth.config.json\n'
        'Example: clean_gen create config/auth.config.json --output lib/features\n'
        'Example: clean_gen create config/auth.config.json --model generate',
      );
    }

    await _createFromConfig(configPath);
  }

  Future<void> _createFromConfig(String configPath) async {
    final progress = _logger.progress('Loading config...');

    try {
      // Resolve absolute path
      final resolvedPath = p.absolute(configPath);
      final configFile = File(resolvedPath);

      if (!configFile.existsSync()) {
        progress.fail('Config file not found: $resolvedPath');
        return;
      }

      // Extract feature name from filename (auth.config.json -> auth)
      final fileName = p.basename(resolvedPath);
      final featureName = _extractFeatureName(fileName);

      if (featureName.isEmpty) {
        progress.fail(
          'Invalid config filename. Expected format: <feature-name>.config.json\n'
          'Example: auth.config.json',
        );
        return;
      }

      // Parse config
      final configContent = await configFile.readAsString();
      Map<String, dynamic> configJson;

      if (resolvedPath.endsWith('.json')) {
        configJson = jsonDecode(configContent) as Map<String, dynamic>;
      } else {
        final yaml = loadYaml(configContent);
        configJson = _yamlToMap(yaml) as Map<String, dynamic>;
      }

      // Load global config
      final globalConfig = await _loadGlobalConfig();
      final schema = FeatureSchema.fromJson(configJson, globalConfig);

      // Validate schema
      if (!schema.isValid()) {
        progress.fail('Invalid schema in $configPath');
        _logger.err(
          'Please ensure "name" is not empty and all "functions" have a "name" and "api".',
        );
        _logger.err(
          'Valid methods are: ${FunctionDef.validMethods.join(', ')}',
        );
        return;
      }

      progress.complete('Config loaded: $featureName');

      // Get output path
      final outputPath = argResults!['output'] as String;
      final featureOutputPath = p.join(outputPath, featureName);

      // Create feature directory structure
      await _initializeFeature(
        featureOutputPath,
        featureName,
        schema.functions.isNotEmpty,
      );

      // If functions exist, generate all files
      if (schema.functions.isNotEmpty) {
        final modelStrategy = argResults!['model'] as String;
        await _generateFeatureFiles(featureOutputPath, schema, modelStrategy);
      } else {
        _logger.info(
          'No functions defined in config. Generated folder structure only.\n'
          'To add API functions, update your original config file and re-run the create command',
        );
      }

      _logger.success(
        '✓ Feature created successfully!\n'
        '  Feature: $featureName\n'
        '  Output: $featureOutputPath\n'
        '  Functions: ${schema.functions.length}',
      );
    } catch (e) {
      progress.fail('Failed to create feature: $e');
      _logger.err(e.toString());
      rethrow;
    }
  }

  String _extractFeatureName(String fileName) {
    // Remove .config.json or .config.yaml/yml extension
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

  Future<void> _initializeFeature(
    String basePath,
    String featureName,
    bool hasFunctions,
  ) async {
    final progress = _logger.progress('Initializing architecture...');

    try {
      // Create directory if it doesn't exist
      final baseDir = Directory(basePath);
      if (!baseDir.existsSync()) {
        baseDir.createSync(recursive: true);
      }

      // Define folder structure
      final folders = [
        'data/data_sources',
        'data/models',
        'data/repositories',
        'domain/repositories',
        'domain/use_cases',
        'presentation/cubit',
        'presentation/pages',
        'presentation/widgets',
      ];

      // Create all folders
      for (final folder in folders) {
        final folderPath = p.join(basePath, folder);
        Directory(folderPath).createSync(recursive: true);
      }

      // Create .gitkeep files
      for (final folder in folders) {
        bool shouldSkipGitkeep = false;
        if (hasFunctions) {
          final folderName = p.basename(folder);
          if (folderName == 'use_cases' ||
              folderName == 'data_sources' ||
              folderName == 'models' ||
              folderName == 'repositories' ||
              folderName == 'cubit') {
            shouldSkipGitkeep = true;
          }
        }

        if (!shouldSkipGitkeep) {
          final gitkeepPath = p.join(basePath, folder, '.gitkeep');
          await File(gitkeepPath).create(recursive: true);
        }
      }

      progress.complete('Architecture initialized');
    } catch (e) {
      progress.fail('Failed to initialize: $e');
      rethrow;
    }
  }

  // Note: .arch.json generation was intentionally removed. The config file
  // provided to the `create` command is the single source of truth for the
  // feature (do not rely on a generated .arch.json). If you want to persist
  // state inside the feature folder, add files manually after generation.

  Future<void> _generateFeatureFiles(
    String basePath,
    FeatureSchema schema,
    String modelStrategy,
  ) async {
    final progress = _logger.progress('Generating feature files...');

    try {
      final generator = FeatureGenerator(logger: _logger);
      await generator.generate(
        basePath: basePath,
        schema: schema,
        modelStrategy: modelStrategy,
      );
      progress.complete('Feature files generated');
    } catch (e) {
      progress.fail('Failed to generate files: $e');
      rethrow;
    }
  }
}
