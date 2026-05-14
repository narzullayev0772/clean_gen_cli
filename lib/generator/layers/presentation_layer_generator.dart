import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;
import 'package:clean_gen_cli/generator/models/feature_schema.dart';
import 'package:clean_gen_cli/generator/templates/cubit_template.dart';
import 'package:clean_gen_cli/generator/utils/file_writer.dart';

class PresentationLayerGenerator {
  final Logger logger;

  PresentationLayerGenerator({required this.logger});

  Future<void> generate({
    required String basePath,
    required FeatureSchema schema,
  }) async {
    try {
      final presentationPath = p.join(basePath, 'presentation');

      // Generate Cubit
      await _generateCubit(presentationPath, schema);

      logger.info('✓ Presentation layer generated for ${schema.name}');
    } catch (e) {
      logger.err('Failed to generate presentation layer: $e');
      rethrow;
    }
  }

  Future<void> _generateCubit(
    String presentationPath,
    FeatureSchema schema,
  ) async {
    final snakeName = FileWriter.toSnakeCase(schema.name);
    final managerPath = p.join(presentationPath, 'cubit');

    // Generate Cubit
    final cubbitContent = CubitTemplate.generate(schema);
    await FileWriter.createDartFile(
      dirPath: managerPath,
      fileName: '${snakeName}_cubit.dart',
      content: cubbitContent,
    );

    // Generate State
    final stateContent = CubitStateTemplate.generate(schema);
    await FileWriter.createDartFile(
      dirPath: managerPath,
      fileName: '${snakeName}_state.dart',
      content: stateContent,
    );
  }
}
