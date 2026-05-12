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
    final stateContent = CubitStateTemplate.generate(featureName, functions);
    await FileWriter.createDartFile(
      dirPath: managerPath,
      fileName: '${snakeName}_state.dart',
      content: stateContent,
    );
  }
}

