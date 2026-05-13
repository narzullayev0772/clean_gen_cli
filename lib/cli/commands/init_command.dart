import 'dart:convert';
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;

class InitCommand extends Command<void> {
  final Logger _logger;

  @override
  final String name = 'init';
  @override
  final String description = 'Initializes the global configuration file.';

  InitCommand({Logger? logger}) : _logger = logger ?? Logger();

  @override
  Future<void> run() async {
    final path = argResults?.rest.firstOrNull ?? p.join('config', 'config.json');
    final progress = _logger.progress('Initializing global config...');

    try {
      final configFile = File(path);
      if (configFile.existsSync()) {
        progress.fail('Global config already exists: ${configFile.path}');
        return;
      }

      final configDir = configFile.parent;
      if (!configDir.existsSync()) {
        configDir.createSync(recursive: true);
      }

      final defaultConfig = {
        'imports': {
          'core': 'package:core/core.dart',
          'fetcher': 'package:core/utils/fetcher.dart'
        },
        'config': {
          'base_url': 'https://api.example.com'
        }
      };

      await configFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(defaultConfig),
      );

      progress.complete('Global config initialized: ${configFile.path}');
    } catch (e) {
      progress.fail('Failed to initialize: $e');
      rethrow;
    }
  }
}
