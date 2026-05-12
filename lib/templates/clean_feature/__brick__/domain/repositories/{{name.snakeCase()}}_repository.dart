// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:core/core.dart';
import '../../data/models/{{name.snakeCase()}}_model.dart';

abstract class {{name.pascalCase()}}Repository {
  Future<DataState<List<{{name.pascalCase()}}Model>?>> fetch{{name.pascalCase()}}();
}
