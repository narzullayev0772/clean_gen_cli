import 'dart:io';
import 'package:clean_gen_cli/cli/command_runner.dart';
import 'package:mason/mason.dart';

void main(List<String> arguments) async {
  final logger = Logger();
  final runner = CleanGenCommandRunner(logger: logger);

  try {
    await runner.run(arguments);
  } catch (e) {
    logger.err(e.toString());
    exit(64);
  }
}
