import 'package:core/core.dart';
import '../../data/models/{{name.snakeCase()}}_model.dart';
import '../repositories/{{name.snakeCase()}}_repository.dart';

class Fetch{{name.pascalCase()}}UseCase {
  final {{name.pascalCase()}}Repository _repository;

  Fetch{{name.pascalCase()}}UseCase(this._repository);

  Future<DataState<List<{{name.pascalCase()}}Model>?>> call() async =>
      await _repository.fetch{{name.pascalCase()}}();
}
