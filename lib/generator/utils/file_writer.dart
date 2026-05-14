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

  static Future<void> injectToClass({
    required String filePath,
    required String newContent,
    String? anchor,
  }) async {
    final file = File(filePath);
    if (!file.existsSync()) return;

    String content = await file.readAsString();

    if (anchor != null && content.contains(anchor)) {
      content = content.replaceFirst(anchor, '$newContent\n  $anchor');
    } else {
      // If no anchor, inject before the last closing brace
      final lastBraceIndex = content.lastIndexOf('}');
      if (lastBraceIndex != -1) {
        content =
            content.substring(0, lastBraceIndex) +
            '\n  $newContent\n' +
            content.substring(lastBraceIndex);
      }
    }

    await file.writeAsString(content, flush: true);
  }

  static Future<void> injectTopLevel({
    required String filePath,
    required String newContent,
  }) async {
    final file = File(filePath);
    if (!file.existsSync()) return;

    String content = await file.readAsString();
    // Prevent duplicate imports
    if (content.contains(newContent.trim())) return;

    // Typically for imports, we want them at the top
    await file.writeAsString('$newContent\n$content', flush: true);
  }
}
