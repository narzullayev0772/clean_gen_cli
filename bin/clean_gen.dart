import 'dart:io';
import 'package:args/args.dart';
import 'package:clean_gen_cli/generator/clean_generator.dart';
import 'package:mason/mason.dart';

void main(List<String> arguments) async {
  final parser = ArgParser();
  final logger = Logger();
  
  final results = parser.parse(arguments);
  
  if (results.rest.isEmpty) {
    logger.info('Usage: clean_gen <feature_name> [output_path]');
    exit(64);
  }

  final featureName = results.rest[0];
  final outputPath = results.rest.length > 1 
      ? results.rest[1] 
      : 'lib/src/features/';

  final generator = CleanGenerator(logger: logger);
  await generator.generate(featureName, outputPath);
}
