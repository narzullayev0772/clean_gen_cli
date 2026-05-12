import 'package:path/path.dart' as p;
import 'package:clean_gen_cli/generator/models/feature_schema.dart';
import 'package:clean_gen_cli/generator/templates/cubit_template.dart';
import 'package:clean_gen_cli/generator/utils/file_writer.dart';
import 'package:mason/mason.dart';

class PresentationLayerGenerator {
  final Logger logger;

  PresentationLayerGenerator({required this.logger});

  Future<void> generate({
    required String basePath,
    required String featureName,
    required List<FunctionDef> functions,
  }) async {
    try {
      final presentationPath = p.join(basePath, 'presentation');

      // Generate Cubit
      await _generateCubit(presentationPath, featureName, functions);

      // Generate Pages (placeholder)
      await _generatePages(presentationPath, featureName);

      // Generate Widgets (placeholder)
      await _generateWidgets(presentationPath, featureName);

      logger.info('✓ Presentation layer generated for $featureName');
    } catch (e) {
      logger.err('Failed to generate presentation layer: $e');
      rethrow;
    }
  }

  Future<void> _generateCubit(
    String presentationPath,
    String featureName,
    List<FunctionDef> functions,
  ) async {
    final snakeName = FileWriter.toSnakeCase(featureName);
    final managerPath = p.join(presentationPath, 'cubit');

    // Generate Cubit
    final cubbitContent = CubitTemplate.generate(featureName, functions);
    await FileWriter.createDartFile(
      dirPath: managerPath,
      fileName: '${snakeName}_cubit.dart',
      content: cubbitContent,
    );

    // Generate State
    final stateContent = CubitStateTemplate.generate(featureName);
    await FileWriter.createDartFile(
      dirPath: managerPath,
      fileName: '${snakeName}_state.dart',
      content: stateContent,
    );
  }

  Future<void> _generatePages(String presentationPath, String featureName) async {
    final pagesPath = p.join(presentationPath, 'pages');
    final snakeName = FileWriter.toSnakeCase(featureName);


    final content = '''import 'package:flutter/material.dart';

class ${FileWriter.toCamelCase(snakeName)}Screen extends StatefulWidget {
  const ${FileWriter.toCamelCase(snakeName)}Screen({Key? key}) : super(key: key);

  @override
  State<${FileWriter.toCamelCase(snakeName)}Screen> createState() => _${FileWriter.toCamelCase(snakeName)}ScreenState();
}

class _${FileWriter.toCamelCase(snakeName)}ScreenState extends State<${FileWriter.toCamelCase(snakeName)}Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('${FileWriter.toCamelCase(snakeName)}')),
      body: const Center(child: Text('TODO: Implement UI')),
    );
  }
}
''';

    await FileWriter.createDartFile(
      dirPath: pagesPath,
      fileName: '${snakeName}_screen.dart',
      content: content,
    );
  }

  Future<void> _generateWidgets(String presentationPath, String featureName) async {
    final widgetsPath = p.join(presentationPath, 'widgets');
    final snakeName = FileWriter.toSnakeCase(featureName);

    final content = '''import 'package:flutter/material.dart';

// TODO: Add your custom widgets here
// Example:
// class ${FileWriter.toCamelCase(snakeName)}Widget extends StatelessWidget {
//   const ${FileWriter.toCamelCase(snakeName)}Widget({Key? key}) : super(key: key);
// 
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Text('Your widget here'),
//     );
//   }
// }
''';

    await FileWriter.createDartFile(
      dirPath: widgetsPath,
      fileName: '._placeholder',
      content: content,
    );
  }
}

