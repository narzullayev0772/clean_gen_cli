import 'dart:io';
import 'package:path/path.dart' as p;

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

  static String toCamelCase(String input) {
    if (input.isEmpty) return input;
    final camel = input.split('_').map((s) => s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1)).join();
    return camel[0].toUpperCase() + camel.substring(1);
  }

  static String toLowerCamelCase(String input) {
    if (input.isEmpty) return input;
    final camel = toCamelCase(input);
    return camel[0].toLowerCase() + camel.substring(1);
  }

  static String toSnakeCase(String input) {
    return input
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => '_${match.group(1)!.toLowerCase()}')
        .replaceFirst(RegExp(r'^_'), '')
        .toLowerCase();
  }

  static String toConstName(String input) {
    return input
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m.group(1)}_${m.group(2)}')
        .replaceAllMapped(RegExp(r'[-/]'), (m) => '_')
        .toUpperCase();
  }
}

