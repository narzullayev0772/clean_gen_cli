import 'package:clean_gen_cli/generator/base_generator.dart';
import 'package:path/path.dart' as p;
import 'package:recase/recase.dart';

class CleanGenerator extends BaseGenerator {
  CleanGenerator({super.logger});

  /// Generates the complete feature structure and files based on uyqur_app style.
  Future<void> generateFullFeature(String featureName, String outputPath, {bool useCubit = true}) async {
    await generate(
      brickName: 'clean_feature',
      vars: {'name': featureName, 'use_cubit': useCubit},
      targetDirectory: p.join(outputPath, featureName.snakeCase),
    );
  }

  /// Legacy support for generating only folders (updated to new structure)
  Future<void> generateFolders(String featureName, String outputPath) async {
    // In the new version, generateFullFeature handles everything,
    // but if we only want folders, we can use this.
    // For now, let's keep it simple and use the main brick.
    await generateFullFeature(featureName, outputPath);
  }

  /// Legacy support for generating code files separately
  Future<void> generateCode({required String featureName, required String outputPath, bool useCubit = true}) async {
    await generateFullFeature(featureName, outputPath, useCubit: useCubit);
  }
}
