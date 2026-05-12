import 'dart:io';
import 'package:args/args.dart';
import 'package:clean_gen_cli/generator/clean_generator.dart';

void main(List<String> arguments) async {
  final parser = ArgParser();
  
  // We can add options here if needed, but the user asked for positional arguments.
  // clean_gen <feature_name> <output_path>
  
  final results = parser.parse(arguments);
  
  if (results.rest.isEmpty) {
    print('Usage: clean_gen <feature_name> [output_path]');
    exit(64);
  }

  final featureName = results.rest[0];
  final outputPath = results.rest.length > 1 
      ? results.rest[1] 
      : 'lib/src/features/';

  final generator = CleanGenerator();
  await generator.generate(featureName, outputPath);
}
