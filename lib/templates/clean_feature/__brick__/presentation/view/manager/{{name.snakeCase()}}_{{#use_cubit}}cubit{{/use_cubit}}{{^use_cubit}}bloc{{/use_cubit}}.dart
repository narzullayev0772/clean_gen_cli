import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/use_cases/fetch_{{name.snakeCase()}}_use_case.dart';

part '{{name.snakeCase()}}_state.dart';
{{^use_cubit}}part '{{name.snakeCase()}}_event.dart';{{/use_cubit}}

class {{name.pascalCase()}}{{#use_cubit}}Cubit{{/use_cubit}}{{^use_cubit}}Bloc{{/use_cubit}} extends {{#use_cubit}}Cubit{{/use_cubit}}{{^use_cubit}}Bloc{{/use_cubit}}<{{#use_cubit}}{{name.pascalCase()}}State{{/use_cubit}}{{^use_cubit}}{{name.pascalCase()}}Event, {{name.pascalCase()}}State{{/use_cubit}}> {
  final Fetch{{name.pascalCase()}}UseCase _fetch{{name.pascalCase()}}UseCase;

  {{name.pascalCase()}}{{#use_cubit}}Cubit{{/use_cubit}}{{^use_cubit}}Bloc{{/use_cubit}}(this._fetch{{name.pascalCase()}}UseCase) : super({{name.pascalCase()}}Initial());

  Future<void> load{{name.pascalCase()}}() async {
    emit({{name.pascalCase()}}Loading());
    try {
      final result = await _fetch{{name.pascalCase()}}UseCase();
      // handle result
      emit({{name.pascalCase()}}Loaded());
    } catch (e) {
      emit({{name.pascalCase()}}Error(e.toString()));
    }
  }
}
