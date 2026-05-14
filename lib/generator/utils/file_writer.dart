import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:recase/recase.dart';

class FileWriter {
  static Future<void> createDartFile({
    required String dirPath,
    required String fileName,
    required String content,
  }) async {
    await _ensureDirectory(dirPath);

    final filePath = p.join(dirPath, fileName);
    final file = File(filePath);

    await file.writeAsString(content, flush: true);
  }

  static Future<void> _ensureDirectory(String dirPath) async {
    final dir = Directory(dirPath);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
  }

  static String toCamelCase(String input) => ReCase(input).pascalCase;

  static String toLowerCamelCase(String input) => ReCase(input).camelCase;

  static String toSnakeCase(String input) => ReCase(input).snakeCase;

  static String toConstName(String input) => ReCase(input).constantCase;
}
