import 'package:core/core.dart';
import '../../domain/repositories/{{name.snakeCase()}}_repository.dart';
import '../data_sources/{{name.snakeCase()}}_api_service.dart';
import '../models/{{name.snakeCase()}}_model.dart';

class {{name.pascalCase()}}RepositoryImpl implements {{name.pascalCase()}}Repository {
  final {{name.pascalCase()}}ApiService _apiService;

  {{name.pascalCase()}}RepositoryImpl(this._apiService);

  @override
  Future<DataState<List<{{name.pascalCase()}}Model>?>> fetch{{name.pascalCase()}}() async {
    // TODO: implement fetch{{name.pascalCase()}}
    throw UnimplementedError();
  }
}
